From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 5/5] vxlan: implement GPE in L3 mode
Date: Sat, 27 Feb 2016 20:21:59 +0100
Message-ID: <20160227202159.6507b8b9@griffin>
References: <cover.1456472746.git.jbenc@redhat.com>
	<20f9916704dc3b34526bc0959e7212de7ec878a4.1456472746.git.jbenc@redhat.com>
	<CAEh+42hC=Bx3FFGH=Eij-HGNN5jgZh_PmBbzp_3YPnWKpyTn1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37271 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751389AbcB0TWD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2016 14:22:03 -0500
In-Reply-To: <CAEh+42hC=Bx3FFGH=Eij-HGNN5jgZh_PmBbzp_3YPnWKpyTn1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Feb 2016 14:22:03 -0800, Jesse Gross wrote:
> Given that VXLAN_GPE_MODE_L3 will eventually come to be used by NSH,
> MPLS, etc. in addition to IPv4/v6, most of which are not really L3, it
> seems like something along the lines of NO_ARP might be better since
> that's what it really indicates.

I have no problem naming this differently. Not sure NO_ARP is the best
name, though - this is more about absence of the L2 header in received
packets than about ARP.

> Once that is in, I don't really see
> the need to explicitly block Ethernet packets from being handled in
> this mode. If they are received, then they can just be handed off to
> the stack - at that point it would look like an extra header, the same
> as if an NSH packet is received.

You mean returning ETH_P_TEB in skb->protocol? That's not much useful,
unfortunately. You won't get such packet processed by the kernel IP
stack, rendering the VXLAN-GPE device unusable outside of ovs. It would
effectively became a packet sink when used standalone, as it cannot be
added to bridge and received packets are not processed by anything -
there's no protocol handler for ETH_P_TEB.

With this patchset, you can create a VXLAN-GPE interface and use it as
any other point to point interface, and it works as expected with
routing etc.

The distinction between Ethernet and no Ethernet is needed, the
interface won't work otherwise.

 Jiri
