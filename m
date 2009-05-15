From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: [PATCH 4/5] addrconf: refuse isatap eui64 for INADDR_ANY
Date: Fri, 15 May 2009 14:52:50 +0200
Message-ID: <1242391971-32583-4-git-send-email-contact@saschahlusiak.de>
References: <1242391971-32583-1-git-send-email-contact@saschahlusiak.de>
 <1242391971-32583-2-git-send-email-contact@saschahlusiak.de>
 <1242391971-32583-3-git-send-email-contact@saschahlusiak.de>
Cc: Sascha Hlusiak <contact@saschahlusiak.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:62231 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755515AbZEOMwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 08:52:14 -0400
In-Reply-To: <1242391971-32583-3-git-send-email-contact@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A tunnel with no local ipv4 endpoint would otherwise use the
ISATAP linklocal address fe80::5efe:0:0, which is invalid. Rather not
add a linklocal address at all.
---
 net/ipv6/addrconf.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a8218bc..550fb79 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1520,6 +1520,8 @@ static int addrconf_ifid_infiniband(u8 *eui, struct net_device *dev)
 
 int __ipv6_isatap_ifid(u8 *eui, __be32 addr)
 {
+	if (addr == 0)
+		return -1;
 	eui[0] = (ipv4_is_zeronet(addr) || ipv4_is_private_10(addr) ||
 		  ipv4_is_loopback(addr) || ipv4_is_linklocal_169(addr) ||
 		  ipv4_is_private_172(addr) || ipv4_is_test_192(addr) ||
-- 
1.6.3

