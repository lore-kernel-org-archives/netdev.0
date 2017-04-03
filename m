From: Simon Horman <simon.horman@netronome.com>
Subject: Re: Pointer type of _arp in __skb_flow_dissect()
Date: Mon, 3 Apr 2017 04:47:15 -0400
Message-ID: <20170403084714.GB30894@vergenet.net>
References: <9bb97603-3b86-73cb-8ed8-c421055138a6@m4x.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9bb97603-3b86-73cb-8ed8-c421055138a6@m4x.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Nicolas,

thanks for pointing this out.

On Fri, Mar 31, 2017 at 08:53:10PM +0200, Nicolas Iooss wrote:
> Hello,
> 
> Linux 4.11-rc4 contains the following code in function
> __skb_flow_dissect(), file net/core/flow_dissector.c:
> 
> 	const struct arphdr *arp;
> 	struct arphdr *_arp;

It looks like *_arp should be _arp.
And it looks like this affects net, since v4.11-rc1, and net-next.
I'll test the fix and post a patch unless someone beats me to it.

> 
> 	arp = __skb_header_pointer(skb, nhoff, sizeof(_arp), data,
> 				   hlen, &_arp);
> 
> 
> Here _arp and arp are both pointers to arphdr structures. In other calls
> to __skb_header_pointer(), the buffer argument (_arp here) would have
> been a struct instead of a pointer. What makes ARP packets different in
> __skb_flow_dissect()?
> 
> Thanks,
> Nicolas
> 
> PS: the code which I am curious about seems to have been introduced in
> 4.11-rc1 with commit 55733350e5e8 ("flow disector: ARP support")
