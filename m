From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 04/10] vxlan: send notification when MAC migrates
Date: Tue,  4 Jun 2013 21:24:08 -0700
Message-ID: <1370406254-6341-4-git-send-email-stephen@networkplumber.org>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:50077 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078Ab3FEEYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 00:24:25 -0400
Received: by mail-pd0-f171.google.com with SMTP id z11so1237319pdj.30
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 21:24:24 -0700 (PDT)
In-Reply-To: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When learned entry migrates to another IP send a notification
that entry has changed.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vxlan.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f98f459..25d3e9e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -628,6 +628,7 @@ static int vxlan_snoop(struct net_device *dev,
 
 		f->remote.remote_ip = src_ip;
 		f->updated = jiffies;
+		vxlan_fdb_notify(vxlan, f, RTM_NEWNEIGH);
 	} else {
 		/* learned new entry */
 		spin_lock(&vxlan->hash_lock);
-- 
1.7.10.4
