From: Dan Carpenter <error27@gmail.com>
Subject: [patch] vxge: remove duplicated part of check
Date: Fri, 24 Dec 2010 09:15:39 +0300
Message-ID: <20101224061539.GP1936@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Jon Mason <jon.mason@exar.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Ramkrishna Vepa <ramkrishna.vepa@exar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64500 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763Ab0LXGPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Dec 2010 01:15:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is just a cleanup to make the static checkers happy.  We don't need
to check "own" twice.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-traffic.c
index 42cc298..4c10d6c 100644
--- a/drivers/net/vxge/vxge-traffic.c
+++ b/drivers/net/vxge/vxge-traffic.c
@@ -1240,7 +1240,7 @@ enum vxge_hw_status vxge_hw_ring_rxd_next_completed(
 	*t_code	= (u8)VXGE_HW_RING_RXD_T_CODE_GET(control_0);
 
 	/* check whether it is not the end */
-	if (!own || ((*t_code == VXGE_HW_RING_T_CODE_FRM_DROP) && own)) {
+	if (!own || *t_code == VXGE_HW_RING_T_CODE_FRM_DROP) {
 
 		vxge_assert(((struct vxge_hw_ring_rxd_1 *)rxdp)->host_control !=
 				0);
