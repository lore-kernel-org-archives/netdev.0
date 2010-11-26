From: Li Yang <leoli@freescale.com>
Subject: [PATCH] ucc_geth: fix ucc halt problem in half duplex mode
Date: Fri, 26 Nov 2010 17:29:58 +0800
Message-ID: <1290763798-22844-1-git-send-email-leoli@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Anton Vorontsov <avorontsov@ru.mvista.com>,
	Jean-Denis Boyer <jdboyer@media5corp.com>,
	Andreas Schmitz <Andreas.Schmitz@riedel.net>
To: <linuxppc-dev@lists.ozlabs.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

In commit 58933c64(ucc_geth: Fix the wrong the Rx/Tx FIFO size),
the UCC_GETH_UTFTT_INIT is set to 512 based on the recommendation
of the QE Reference Manual.  But that will sometimes cause tx halt
while working in half duplex mode.

According to errata draft QE_GENERAL-A003(High Tx Virtual FIFO
threshold size can cause UCC to halt), setting UTFTT less than
[(UTFS x (M - 8)/M) - 128] will prevent this from happening
(M is the minimum buffer size).

The patch changes UTFTT back to 256.

Signed-off-by: Li Yang <leoli@freescale.com>
Cc: Jean-Denis Boyer <jdboyer@media5corp.com>
Cc: Andreas Schmitz <Andreas.Schmitz@riedel.net>
Cc: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index 05a9558..a78b9c0 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -899,7 +899,8 @@ struct ucc_geth_hardware_statistics {
 #define UCC_GETH_UTFS_INIT                      512	/* Tx virtual FIFO size
 							 */
 #define UCC_GETH_UTFET_INIT                     256	/* 1/2 utfs */
-#define UCC_GETH_UTFTT_INIT                     512
+#define UCC_GETH_UTFTT_INIT                     256	/* 1/2 utfs
+							   due to errata */
 /* Gigabit Ethernet (1000 Mbps) */
 #define UCC_GETH_URFS_GIGA_INIT                 4096/*2048*/	/* Rx virtual
 								   FIFO size */
-- 
1.6.6-rc1.GIT
