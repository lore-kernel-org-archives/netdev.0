From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2:  receive dma mapping error handling
Date: Wed, 03 Feb 2010 11:47:19 -0500
Message-ID: <4B69A897.7030408@majjas.com>
References: <20100128223447.GC3109@del.dom.local> <4B621316.8070308@majjas.com>
 <20100128225621.GD3109@del.dom.local> <4B6216B9.1010802@majjas.com>
 <20100128153643.0fca3c51@nehalam> <4B645EF4.4050701@majjas.com>
 <20100131003449.GA11935@del.dom.local> <4B650D53.2010607@majjas.com>
 <4B65D0F9.2020602@majjas.com> <4B65FD12.7090101@majjas.com>
 <20100131221835.GA3317@del.dom.local> <20100201102018.7b597992@nehalam>
 <4B68F664.6050007@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <4B68F664.6050007@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/02/2010 11:07 PM, Michael Breuer wrote:
> Just a brief update - this has been up and stable for about 32 hours - 
> I've been periodically generating load on the system. No kernel errors 
> of any sort so far. Actually, in retrospect, I believe the dma issue 
> was triggering other bad things - including an rcu lockup (patched in 
> tip - sched.c).
>
> Just as an FYI - (and this should probably be in a new thread) I am 
> seeing an large number (>9,000,000) of dropped rx packets, however at 
> this time I see no errors resulting from that (on this or client 
> machines). As the # of dropped packets hasn't incremented at any time 
> I was observing things, I can't say what this is about. Probably 
> nothing, but I'll see if I can track down what is going on. I did see 
> some of this earlier on while troubleshooting the sky2 issues that now 
> seem resolved.  Quick crosschecking of other machines do not show high 
> error or retransmission rates. I'm also not seeing any evidence of 
> other errors (no errors reported by ifconfig, or ethtool, or printk 
> (debug is enabled).
>
> I'm wondering whether these dropped packets are due mostly to hitting 
> GMR_FS_RX_OK in sky2_receive. I'm also guessing that the high numbers 
> of this that I'm seeing is an artifact of being able to pump more 
> traffic through with the above patch. Given the description of the 
> status code in sky2.h (receive ok) I'm wondering whether a) this 
> should be reported as dropped, b) whether resubmit is necessary, c) 
> whether it's possible that eth1 events coinciding with eth0 events are 
> the cause and d) whether or not there's another issue entirely.
>
Tracked this down. The status being returned is 0x3c0080 - good flow 
control packets. Nothing is actually being dropped (confirmed by packet 
trace on switch compared with packet trace on server).

I whipped up a trivial patch to not count these as dropped packets and 
will post to netdev.

I'm not really sure what the driver should be doing in this case, but 
resubmit seems to work.
