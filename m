From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next RFC 0/5] xen-netback: TX grant mapping instead
 of copy
Date: Thu, 28 Nov 2013 17:43:12 +0000
Message-ID: <1385660592.20209.27.camel@kazak.uk.xensource.com>
References: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com>
		 <1383303035.672.29.camel@kazak.uk.xensource.com>
		 <5273FA37.6020903@citrix.com>
	 <1383821563.26213.168.camel@kazak.uk.xensource.com>
	 <52977F5C.7090703@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52977F5C.7090703@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-11-28 at 17:37 +0000, Zoltan Kiss wrote:
> On 07/11/13 10:52, Ian Campbell wrote:
> > On Fri, 2013-11-01 at 19:00 +0000, Zoltan Kiss wrote:
> >> On 01/11/13 10:50, Ian Campbell wrote:
> >>> Does this always avoid copying when bridging/openvswitching/forwarding
> >>> (e.g. masquerading etc)? For both domU->domU and domU->physical NIC?
> >> I've tested the domU->domU, domU->physical with bridge and openvswitch
> >> usecase, and now I've created a new stat counter to see how often copy
> >> happens (the callback's second parameter tells you whether the skb was
> >> freed or copied). It doesn't do copy in all of these scenarios.
> >> What do you mean by forwarding? The scenario when you use bridge and
> >> iptables mangling with the packet, not just filtering?
> >
> > I mean using L3 routing rather L2 bridging. Which might involve
> > NAT/MASQUERADE or might just be normal IP routing.
> I still couldn't find time to try out this scenario, but I think in this 
> case packet goes through deliver_skb, which means it will get copied. So 
> performance would be a bit worse due to the extra map/unmap. And I'm 
> afraid we can't help that too much due to this:
> https://lkml.org/lkml/2012/7/20/363
> However I think using Dom0 as a router/firewall is already a suboptimal 
> solution, so maybe a small performance regression is acceptable?

Routing/firewalling domUs is as valid as bridging. There is nothing in
the slightest bit suboptimal about it.

If this use case regresses with this approach then I'm afraid that
either needs to be addressed or a different approach considered.

> Anyway, I will try this out, and see if it really copies everything, and 
> get some numbers as well.

Thanks.

> >>> How does it deal with broadcast traffic?
> Now I had time to check it: broadcast packets get copied only once, when 
> cloning happens. It will swap out the frags with local ones, so any 
> subsequent cloning will have a local SKB.

That's good.

Ian.
