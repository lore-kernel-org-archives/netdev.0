From: David Howells <dhowells@redhat.com>
Subject: Getting a NIC's MTU size
Date: Fri, 14 Feb 2014 15:49:17 +0000
Message-ID: <27696.1392392957@warthog.procyon.org.uk>
References: <20140214150328.GB27343@order.stressinduktion.org> <20140214144412.GA27343@order.stressinduktion.org> <26474.1392388608@warthog.procyon.org.uk> <26769.1392390042@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26133 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751948AbaBNPtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 10:49:21 -0500
In-Reply-To: <20140214150328.GB27343@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


One further question:  If I want to get the MTU size of the NIC through which
packets will go to get to a particular peer, can I do:

	struct rtable *rt;
	struct flowi4 fl4;
	unsigned if_mtu;

	rt = ip_route_output_ports(&init_net, &fl4, NULL,
				   peer->srx.transport.sin.sin_addr.s_addr, 0,
				   htons(7000), htons(7001),
				   IPPROTO_UDP, 0, 0);

	if_mtu = rt->dst->dev->mtu;

	dst_release(&rt->dst);

Or might this go wrong if rt->dst->dev changes under me?  Can it change
without replacing the dst record?

David
