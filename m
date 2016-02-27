From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 5/5] vxlan: implement GPE in L3 mode
Date: Sat, 27 Feb 2016 20:26:09 +0100
Message-ID: <20160227202609.6e19ee67@griffin>
References: <cover.1456472746.git.jbenc@redhat.com>
	<20f9916704dc3b34526bc0959e7212de7ec878a4.1456472746.git.jbenc@redhat.com>
	<CAEh+42hC=Bx3FFGH=Eij-HGNN5jgZh_PmBbzp_3YPnWKpyTn1w@mail.gmail.com>
	<CALx6S357WXaHBs0Tnf=PCcBZGr2Ryv8jr6rms_TWtYDytmRSKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56938 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751389AbcB0T0N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2016 14:26:13 -0500
In-Reply-To: <CALx6S357WXaHBs0Tnf=PCcBZGr2Ryv8jr6rms_TWtYDytmRSKw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Feb 2016 15:42:29 -0800, Tom Herbert wrote:
> Agreed, and I don't see why there even needs to be modes. VXLAN-GPE
> can carry arbitrary protocols with a next-header field. For Ethernet,
> MPLS, IPv4, and IPv6 it should just be a simple mapping of the next
> header to Ethertype for purposes of processing the payload.

That's exactly what this patchset does, Tom. The mapping is done in
vxlan_parse_gpe_hdr and vxlan_build_gpe_hdr.

Ethernet is special, though. It needs to be a standalone mode,
otherwise frames encapsulated including an Ethernet header wouldn't be
processed and there would be no way to send such packets - the only
distinction the driver can use is skb->protocol and that won't become
ETH_P_TEB magically.

 Jiri
