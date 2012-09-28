From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: [PATCH] vlan: Make it possible to add vlan with id 4095
Date: Fri, 28 Sep 2012 15:32:58 +0300
Message-ID: <20120928123258.9454.95197.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:54298 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755400Ab2I1MdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 08:33:02 -0400
Received: by wibhq12 with SMTP id hq12so7809390wib.1
        for <netdev@vger.kernel.org>; Fri, 28 Sep 2012 05:33:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vconfig help tells that vlan_id should be 0-4095, but fails
with 4095.

There is an off-by-one bug while evaluating vlan_id.
Fix it by evaluating against count(4096), not mask(0x0fff = 4095).

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>
---

 net/8021q/vlan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 9096bcb..9e528bf 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -199,7 +199,7 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	char name[IFNAMSIZ];
 	int err;
 
-	if (vlan_id >= VLAN_VID_MASK)
+	if (vlan_id >= VLAN_N_VID)
 		return -ERANGE;
 
 	err = vlan_check_real_dev(real_dev, vlan_id);
