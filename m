From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] bnx2: annotate bp->phy_lock functions
Date: Mon, 19 Jan 2009 12:11:50 -0800
Message-ID: <1232395910.13386.4.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:63142 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752671AbZASUMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 15:12:03 -0500
Received: by wf-out-1314.google.com with SMTP id 27so3368017wfd.4
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2009 12:12:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like the locking is OK as the locks were being taken before the
various phy setup functions, add the annotations as they release and
reacquire the phy_lock.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/bnx2.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d4a3dac..d86a8f2 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1497,6 +1497,8 @@ static int bnx2_fw_sync(struct bnx2 *, u32, int, int);
 
 static int
 bnx2_setup_remote_phy(struct bnx2 *bp, u8 port)
+__releases(&bp->phy_lock)
+__acquires(&bp->phy_lock)
 {
 	u32 speed_arg = 0, pause_adv;
 
@@ -1554,6 +1556,8 @@ bnx2_setup_remote_phy(struct bnx2 *bp, u8 port)
 
 static int
 bnx2_setup_serdes_phy(struct bnx2 *bp, u8 port)
+__releases(&bp->phy_lock)
+__acquires(&bp->phy_lock)
 {
 	u32 adv, bmcr;
 	u32 new_adv = 0;
@@ -1866,6 +1870,8 @@ bnx2_set_remote_link(struct bnx2 *bp)
 
 static int
 bnx2_setup_copper_phy(struct bnx2 *bp)
+__releases(&bp->phy_lock)
+__acquires(&bp->phy_lock)
 {
 	u32 bmcr;
 	u32 new_bmcr;
@@ -1963,6 +1969,8 @@ bnx2_setup_copper_phy(struct bnx2 *bp)
 
 static int
 bnx2_setup_phy(struct bnx2 *bp, u8 port)
+__releases(&bp->phy_lock)
+__acquires(&bp->phy_lock)
 {
 	if (bp->loopback == MAC_LOOPBACK)
 		return 0;
@@ -2176,6 +2184,8 @@ bnx2_init_copper_phy(struct bnx2 *bp, int reset_phy)
 
 static int
 bnx2_init_phy(struct bnx2 *bp, int reset_phy)
+__releases(&bp->phy_lock)
+__acquires(&bp->phy_lock)
 {
 	u32 val;
 	int rc = 0;
-- 
1.6.1.249.g455e5



