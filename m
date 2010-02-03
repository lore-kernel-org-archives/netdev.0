From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2:  receive dma mapping error handling
Date: Wed, 03 Feb 2010 12:07:40 -0500
Message-ID: <4B69AD5C.5030601@majjas.com>
References: <20100128223447.GC3109@del.dom.local> <4B621316.8070308@majjas.com>
 <20100128225621.GD3109@del.dom.local> <4B6216B9.1010802@majjas.com>
 <20100128153643.0fca3c51@nehalam> <4B645EF4.4050701@majjas.com>
 <20100131003449.GA11935@del.dom.local> <4B650D53.2010607@majjas.com>
 <4B65D0F9.2020602@majjas.com> <4B65FD12.7090101@majjas.com>
 <20100131221835.GA3317@del.dom.local> <20100201102018.7b597992@nehalam>
 <4B68F664.6050007@majjas.com> <4B69A897.7030408@majjas.com>
 <20100203085618.6662cc6f@nehalam>
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
In-reply-to: <20100203085618.6662cc6f@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/03/2010 11:56 AM, Stephen Hemminger wrote:
> On Wed, 03 Feb 2010 11:47:19 -0500
> Michael Breuer<mbreuer@majjas.com>  wrote:
>
>    
>> Tracked this down. The status being returned is 0x3c0080 - good flow
>> control packets. Nothing is actually being dropped (confirmed by packet
>> trace on switch compared with packet trace on server).
>>
>> I whipped up a trivial patch to not count these as dropped packets and
>> will post to netdev.
>>
>> I'm not really sure what the driver should be doing in this case, but
>> resubmit seems to work.
>>      
> Looks like a flow control negotiation issue. You probably turned off
> flow control on the Linux side, but the switch is still doing flow
> control.
>
>    
According to the driver:
Feb  3 12:03:02 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full 
duplex, flow control both

So if the rx flow control packet status is due to flow control being 
disabled, then there's a different issue.
