From: Joyce Yu <Joyce.Yu@Sun.COM>
Subject: [PATCH] [NIU] VLAN does not work with niu driver
Date: Wed, 21 Oct 2009 11:02:37 -0700
Message-ID: <4ADF4CBD.90104@Sun.COM>
Reply-To: Joyce.Yu@Sun.COM
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_CK5EEL3jhR4JXab+jdTRaA)"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from brmea-mail-2.Sun.COM ([192.18.98.43]:64092 "EHLO
	brmea-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900AbZJUSCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 14:02:35 -0400
Received: from fe-amer-10.sun.com ([192.18.109.80])
	by brmea-mail-2.sun.com (8.13.6+Sun/8.12.9) with ESMTP id n9LI2dVj024506
	for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 18:02:39 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KRV00D00L9VFR00@mail-amer.sun.com> for netdev@vger.kernel.org; Wed,
 21 Oct 2009 12:02:39 -0600 (MDT)
Received: from [129.145.154.82] ([unknown] [129.145.154.82])
 by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 with ESMTPSA id <0KRV00E25M4D6R90@mail-amer.sun.com> for
 netdev@vger.kernel.org; Wed, 21 Oct 2009 12:02:38 -0600 (MDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--Boundary_(ID_CK5EEL3jhR4JXab+jdTRaA)
Content-type: text/plain; CHARSET=US-ASCII; format=flowed
Content-transfer-encoding: 7BIT


-- 


--Boundary_(ID_CK5EEL3jhR4JXab+jdTRaA)
Content-type: text/x-patch;
 name=0001-VLAN_ETH_HLEN-should-be-used-to-make-sure-that-the-w.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline;
 filename*0=0001-VLAN_ETH_HLEN-should-be-used-to-mak;
 filename*1=e-sure-that-the-w.patch

>From f301748d3156437d65305f14288c7d5711861980 Mon Sep 17 00:00:00 2001
From: Joyce Yu <joyce.yu@sun.com>
Date: Wed, 21 Oct 2009 05:35:46 -0700
Subject: [PATCH] VLAN_ETH_HLEN should be used to make sure that the whole MAC header was copied to the head buffer in the Vlan packets case
Signed-off-by: Joyce Yu <joyce.yu@sun.com>

---
 drivers/net/niu.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index f9364d0..d6c7ac6 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3545,7 +3545,7 @@ static int niu_process_rx_pkt(struct napi_struct *napi, struct niu *np,
 	rp->rcr_index = index;
 
 	skb_reserve(skb, NET_IP_ALIGN);
-	__pskb_pull_tail(skb, min(len, NIU_RXPULL_MAX));
+	__pskb_pull_tail(skb, min(len, VLAN_ETH_HLEN));
 
 	rp->rx_packets++;
 	rp->rx_bytes += skb->len;
-- 
1.6.4


--Boundary_(ID_CK5EEL3jhR4JXab+jdTRaA)--
