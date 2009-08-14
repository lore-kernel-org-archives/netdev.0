From: Davidlohr Bueso <dave@gnu.org>
Subject: [PATCH] s2io: Remove unnecessary casts
Date: Thu, 13 Aug 2009 22:03:28 -0400
Message-ID: <20090814020328.GA21588@fencepost.gnu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: ram.vepa@neterion.com, santosh.rastapur@neterion.com,
	sivakumar.subramani@neterion.com, sreenivasa.honnur@neterion.com,
	anil.murthy@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([140.186.70.10]:34049 "EHLO
	fencepost.gnu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754185AbZHNCDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 22:03:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No need to cast kmalloc.

Signed-off-by: Davidlohr Bueso <dave@gnu.org>

---
 drivers/net/s2io.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 458daa0..43a5abf 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -870,8 +870,7 @@ static int init_shared_mem(struct s2io_nic *nic)
                                while (k != rxd_count[nic->rxd_mode]) {
                                        ba = &mac_control->rings[i].ba[j][k];
 
-                                       ba->ba_0_org = (void *) kmalloc
-                                           (BUF0_LEN + ALIGN_SIZE, GFP_KERNEL);
+                                       ba->ba_0_org = kmalloc(BUF0_LEN + ALIGN_SIZE, GFP_KERNEL);
                                        if (!ba->ba_0_org)
                                                return -ENOMEM;
                                        mem_allocated +=
@@ -881,8 +880,7 @@ static int init_shared_mem(struct s2io_nic *nic)
                                        tmp &= ~((unsigned long) ALIGN_SIZE);
                                        ba->ba_0 = (void *) tmp;
 
-                                       ba->ba_1_org = (void *) kmalloc
-                                           (BUF1_LEN + ALIGN_SIZE, GFP_KERNEL);
+                                       ba->ba_1_org = kmalloc(BUF1_LEN + ALIGN_SIZE, GFP_KERNEL);
                                        if (!ba->ba_1_org)
                                                return -ENOMEM;
                                        mem_allocated
