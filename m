From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 5/5] vxlan: implement GPE in L3 mode
Date: Sat, 27 Feb 2016 20:44:28 +0100
Message-ID: <20160227204428.5f8f25a3@griffin>
References: <cover.1456472746.git.jbenc@redhat.com>
	<20f9916704dc3b34526bc0959e7212de7ec878a4.1456472746.git.jbenc@redhat.com>
	<CAEh+42hC=Bx3FFGH=Eij-HGNN5jgZh_PmBbzp_3YPnWKpyTn1w@mail.gmail.com>
	<20160227202159.6507b8b9@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56766 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751389AbcB0Tob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2016 14:44:31 -0500
In-Reply-To: <20160227202159.6507b8b9@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 27 Feb 2016 20:21:59 +0100, Jiri Benc wrote:
> You mean returning ETH_P_TEB in skb->protocol? That's not much useful,
> unfortunately. You won't get such packet processed by the kernel IP
> stack, rendering the VXLAN-GPE device unusable outside of ovs. It would
> effectively became a packet sink when used standalone, as it cannot be
> added to bridge and received packets are not processed by anything -
> there's no protocol handler for ETH_P_TEB.

Actually, I can do that in the L3 mode (or whatever we'll call it). It
won't hurt anything and may be useful for openvswitch. Ovs will have to
special case VXLAN-GPE vport (or perhaps any ARPHRD_NONE port) and set
skb->protocol to ETH_P_TEB on xmit and dissect correctly the ETH_P_TEB
packet on rcv.

The L2 mode (or whatever we'll call it) will need to stay, though, for
non-ovs use cases.

 Jiri
