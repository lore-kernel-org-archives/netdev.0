From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next RFC 0/5] xen-netback: TX grant mapping instead
 of copy
Date: Thu, 7 Nov 2013 10:52:43 +0000
Message-ID: <1383821563.26213.168.camel@kazak.uk.xensource.com>
References: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com>
	 <1383303035.672.29.camel@kazak.uk.xensource.com>
	 <5273FA37.6020903@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5273FA37.6020903@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-11-01 at 19:00 +0000, Zoltan Kiss wrote:
> On 01/11/13 10:50, Ian Campbell wrote:
> > Does this always avoid copying when bridging/openvswitching/forwarding
> > (e.g. masquerading etc)? For both domU->domU and domU->physical NIC?
> I've tested the domU->domU, domU->physical with bridge and openvswitch 
> usecase, and now I've created a new stat counter to see how often copy 
> happens (the callback's second parameter tells you whether the skb was 
> freed or copied). It doesn't do copy in all of these scenarios.
> What do you mean by forwarding? The scenario when you use bridge and 
> iptables mangling with the packet, not just filtering?

I mean using L3 routing rather L2 bridging. Which might involve
NAT/MASQUERADE or might just be normal IP routing.

> > How does it deal with broadcast traffic?
> Most of the real broadcast traffic actually small packets fit in the 
> PKT_PROT_LEN sized linear space, so it doesn't make any difference, 
> apart from doing a mapping before copy. But that will be eliminated 
> later on, I plan to add an incremental improvement to grant copy the 
> linear part.

OK. If I were a malicious guest and decided to start sending out loads
of huge broadcasts would that lead to a massive spike of activity in
dom0?

> I haven't spent too much time on that, but I couldn't find any broadcast 
> protocol which use large enough packets and easy to test, so I'm open to 
> ideas.

I guess you could hack something up using raw sockets?

> What I already know, skb_clone trigger a copy, and if the caller use the 
> original skb for every cloning, it will do several copy. I think that 
> could be fixed by using the first clone to do any further clones.

Yes. I suppose doing this automatically might be an interesting
extension to SKBTX_DEV_ZEROCOPY?

Ian.
