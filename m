From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] Limit the size of the IPV4 route hash.
Date: Sun, 12 Dec 2004 16:55:46 -0800
Message-ID: <20041212165546.1808536e.davem@davemloft.net>
References: <20041210190025.GA21116@lnx-holt.americas.sgi.com>
	<20041210114829.034e02eb.davem@davemloft.net>
	<20041210210006.GB23222@lnx-holt.americas.sgi.com>
	<20041210130947.1d945422.akpm@osdl.org>
	<20041210232722.GC24468@lnx-holt.americas.sgi.com>
	<20041210153848.5acacd0a.akpm@osdl.org>
	<20041210233700.GA25582@lnx-holt.americas.sgi.com>
	<20041210234037.GB25582@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: holt@sgi.com, akpm@osdl.org, yoshfuji@linux-ipv6.org,
	hirofumi@parknet.co.jp, torvalds@osdl.org, dipankar@ibm.com,
	laforge@gnumonks.org, bunk@stusta.de, herbert@apana.org.au,
	paulmck@ibm.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	gnb@sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262184AbULMBG3@vger.kernel.org>
To: Robin Holt <holt@sgi.com>
In-Reply-To: <20041210234037.GB25582@lnx-holt.americas.sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Dec 2004 17:40:37 -0600
Robin Holt <holt@sgi.com> wrote:

> Sorry, I was asleep at the wheel.  I failed to even grok your second
> paragraph.  I will fall back to agreeing with the printk to let the admin
> know that something is amiss.
> 
> Should we possibly modify the output of /proc/net/rt_cache (or whatever
> its name is) to include the hash bucket so people can watch to see how
> many bucket collisions their system has?

I think there are rt stats for this already added by Robert Olsson.

One thing not mentioned, besides the physically contiguous issue,
is that fact that the locking would need to be changed quite a bit
in order to allow runtime reallocation of the hash table.  The current
code is certainly not ready for it.  It might just work to run the
hash freeing via RCU, but I'm not quite sure.
