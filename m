From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH] vti: remove GRE_KEY flag for vti tunnel
Date: Wed,  4 Dec 2013 16:48:37 +0800
Message-ID: <1386146917-2951-1-git-send-email-liuhangbin@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>,
	Hangbin Liu <liuhangbin@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:33372 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754400Ab3LDItF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 03:49:05 -0500
Received: by mail-pd0-f180.google.com with SMTP id q10so21801485pdj.25
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 00:49:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vti tunnel use IPPROTO_IPIP instead of IPPROTO_GRE, and keys are not allowed
with ipip tunnel. So there is no reason to set GRE_KEY flag for vti.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/ipv4/ip_vti.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 52b802a..58c4e6a 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -185,10 +185,8 @@ vti_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	if (err)
 		return err;
 
-	if (cmd != SIOCDELTUNNEL) {
-		p.i_flags |= GRE_KEY | VTI_ISVTI;
-		p.o_flags |= GRE_KEY;
-	}
+	if (cmd != SIOCDELTUNNEL)
+		p.i_flags |= VTI_ISVTI;
 
 	if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
 		return -EFAULT;
-- 
1.8.1.4
