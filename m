From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 4/10] drivers/net: Move a dereference below a NULL test
Date: Sun, 19 Jul 2009 17:26:35 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0907191726140.16542@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: eilong@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:34805 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754650AbZGSP0h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2009 11:26:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

If the NULL test is necessary, then the dereference should be moved below
the NULL test.

The semantic patch that makes this change is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
type T;
expression E,E1;
identifier i,fld;
statement S;
@@

- T i = E->fld;
+ T i;
  ... when != E=E1
      when != i
  if (E == NULL||...) S
+ i = E->fld;
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/bnx2x_link.c            |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index ed648ac..2ee581a 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -4212,13 +4212,14 @@ static void bnx2x_turn_off_sf(struct bnx2x *bp, u8 port)
 u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 			      u8 *version, u16 len)
 {
-	struct bnx2x *bp = params->bp;
+	struct bnx2x *bp;
 	u32 ext_phy_type = 0;
 	u32 spirom_ver = 0;
 	u8 status = 0 ;
 
 	if (version == NULL || params == NULL)
 		return -EINVAL;
+	bp = params->bp;
 
 	spirom_ver = REG_RD(bp, params->shmem_base +
 		   offsetof(struct shmem_region,
