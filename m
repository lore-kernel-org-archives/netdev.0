From: sfeldma@gmail.com
Subject: [PATCH net-next 2/5] rocker: cleanup vlan table on error adding vlan
Date: Mon,  1 Jun 2015 11:39:03 -0700
Message-ID: <1433183947-13095-3-git-send-email-sfeldma@gmail.com>
References: <1433183947-13095-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36817 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859AbbFASh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 14:37:28 -0400
Received: by pacux9 with SMTP id ux9so74787967pac.3
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 11:37:27 -0700 (PDT)
In-Reply-To: <1433183947-13095-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Basic house keeping: If there is an error adding the router MAC for this
vlan, removing the just installed VLAN table entry to leave device in same
state as before failure.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index ab6d871..76e2281 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4342,7 +4342,12 @@ static int rocker_port_vlan_add(struct rocker_port *rocker_port,
 	if (err)
 		return err;
 
-	return rocker_port_router_mac(rocker_port, trans, 0, htons(vid));
+	err = rocker_port_router_mac(rocker_port, trans, 0, htons(vid));
+	if (err)
+		rocker_port_vlan(rocker_port, trans,
+				 ROCKER_OP_FLAG_REMOVE, vid);
+
+	return err;
 }
 
 static int rocker_port_vlans_add(struct rocker_port *rocker_port,
-- 
1.7.10.4
