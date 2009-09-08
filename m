From: Davidlohr Bueso <dave@gnu.org>
Subject: [PATCH resend] s2io: Remove unnecessary casts
Date: Tue, 08 Sep 2009 00:26:55 -0400
Message-ID: <1252384015.6396.11.camel@dbueso-pc>
Reply-To: dave@gnu.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [186.40.58.177] ([186.40.58.177]:60294 "EHLO
	localhost.localdomain" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752335AbZIHEgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 00:36:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Don't know why my email client corrupted the patch, anyways, here it is without white spaces.

No need to cast kmalloc.

Thanks,
Davidlohr


Signed-off-by: Davidlohr Bueso <dave@gnu.org>

---
 drivers/net/s2io.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 458daa0..2bc62d3 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -870,8 +870,10 @@ static int init_shared_mem(struct s2io_nic *nic)
 				while (k != rxd_count[nic->rxd_mode]) {
 					ba = &mac_control->rings[i].ba[j][k];
 
-					ba->ba_0_org = (void *) kmalloc
-					    (BUF0_LEN + ALIGN_SIZE, GFP_KERNEL);
+					ba->ba_0_org = kmalloc
+						(BUF0_LEN + ALIGN_SIZE,
+						 GFP_KERNEL);
+
 					if (!ba->ba_0_org)
 						return -ENOMEM;
 					mem_allocated +=
@@ -881,9 +883,10 @@ static int init_shared_mem(struct s2io_nic *nic)
 					tmp &= ~((unsigned long) ALIGN_SIZE);
 					ba->ba_0 = (void *) tmp;
 
-					ba->ba_1_org = (void *) kmalloc
-					    (BUF1_LEN + ALIGN_SIZE, GFP_KERNEL);
+					ba->ba_1_org = kmalloc
+						(BUF1_LEN + ALIGN_SIZE,
+						 GFP_KERNEL);
+
 					if (!ba->ba_1_org)
 						return -ENOMEM;
 					mem_allocated
--
1.6.0.4


