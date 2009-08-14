From: Tom Goff <thomas.goff@boeing.com>
Subject: [PATCH] gre: Fix MTU calculation for bound GRE tunnels
Date: Fri, 14 Aug 2009 11:37:58 -0700
Message-ID: <20090814183758.GA21197@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-smtpout-01.boeing.com ([130.76.32.69]:59563 "EHLO
	blv-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415AbZHNSw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 14:52:27 -0400
Received: from slb-av-01.boeing.com (slb-av-01.boeing.com [129.172.13.4])
	by blv-smtpout-01.ns.cs.boeing.com (8.14.0/8.14.0/8.14.0/SMTPOUT) with ESMTP id n7EIbxQ4021293
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 11:38:00 -0700 (PDT)
Received: from slb-av-01.boeing.com (localhost [127.0.0.1])
	by slb-av-01.boeing.com (8.14.0/8.14.0/DOWNSTREAM_RELAY) with ESMTP id n7EIbx5t029850
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 11:37:59 -0700 (PDT)
Received: from packet.blv.boeing.com (packet.blv.boeing.com [130.42.97.136])
	by slb-av-01.boeing.com (8.14.0/8.14.0/UPSTREAM_RELAY) with SMTP id n7EIbwAd029832
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 11:37:58 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The GRE header length should be subtracted when the tunnel MTU is
calculated.  This just corrects for the associativity change
introduced by commit 42aa916265d740d66ac1f17290366e9494c884c2.

Signed-off-by: Tom Goff <thomas.goff@boeing.com>
---
 net/ipv4/ip_gre.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index cb4a0f4..82c11dd 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -951,7 +951,7 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev)
 			addend += 4;
 	}
 	dev->needed_headroom = addend + hlen;
-	mtu -= dev->hard_header_len - addend;
+	mtu -= dev->hard_header_len + addend;
 
 	if (mtu < 68)
 		mtu = 68;
-- 
1.6.0.6

