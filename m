From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Problematic commits in the ipsec tree
Date: Thu, 22 Aug 2013 12:47:24 +0200
Message-ID: <20130822104724.GD26773@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50304 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752494Ab3HVKr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 06:47:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes,

I have two problematic commits from you in the ipsec tree. The first one is:

commit 0ea9d5e3e (xfrm: introduce helper for safe determination of mtu)

This breakes pmtu discovery for IPv4 because now we use the device mtu
instead of the reduced IPsec mtu in xfrm4_tunnel_check_size() if a IPv4
socket is at the skb.

The second is:

commit 844d48746 (xfrm: choose protocol family by skb protocol)

This breaks pmtu discovery for IPv6 too because skb->protocol can be null
in __xfrm6_output().

We need a solution soon, or I have to revert or remove these commits from
the ipsec tree.
