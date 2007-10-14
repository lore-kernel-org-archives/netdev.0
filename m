From: Domen Puncer <domen.puncer@telargo.com>
Subject: [PATCH v3 2/4] FEC mpc52xx: add some bestcomm flags
Date: Sun, 14 Oct 2007 09:58:34 +0200
Message-ID: <20071014075834.GE3000@nd47.coderock.org>
References: <20071014075511.GC3000@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: galak@kernel.crashing.org, jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20071014075511.GC3000@nd47.coderock.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


Add masks and fix existing ones to match mpc5200b user's manual.


Signed-off-by: Domen Puncer <domen.puncer@telargo.com>

---
 arch/powerpc/sysdev/bestcomm/fec.h |   15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

Index: linux.git/arch/powerpc/sysdev/bestcomm/fec.h
===================================================================
--- linux.git.orig/arch/powerpc/sysdev/bestcomm/fec.h
+++ linux.git/arch/powerpc/sysdev/bestcomm/fec.h
@@ -21,7 +21,20 @@ struct bcom_fec_bd {
 };
 
 #define BCOM_FEC_TX_BD_TFD	0x08000000ul	/* transmit frame done */
-#define BCOM_FEC_TX_BD_INT	0x04000000ul	/* interrupt */
+#define BCOM_FEC_TX_BD_TC	0x04000000ul	/* transmit CRC */
+#define BCOM_FEC_TX_BD_ABC	0x02000000ul	/* append bad CRC */
+
+#define BCOM_FEC_RX_BD_L	0x08000000ul	/* buffer is last in frame */
+#define BCOM_FEC_RX_BD_BC	0x00800000ul	/* DA is broadcast */
+#define BCOM_FEC_RX_BD_MC	0x00400000ul	/* DA is multicast and not broadcast */
+#define BCOM_FEC_RX_BD_LG	0x00200000ul	/* Rx frame length violation */
+#define BCOM_FEC_RX_BD_NO	0x00100000ul	/* Rx non-octet aligned frame */
+#define BCOM_FEC_RX_BD_CR	0x00040000ul	/* Rx CRC error */
+#define BCOM_FEC_RX_BD_OV	0x00020000ul	/* overrun */
+#define BCOM_FEC_RX_BD_TR	0x00010000ul	/* Rx frame truncated */
+#define BCOM_FEC_RX_BD_LEN_MASK	0x000007fful	/* mask for length of received frame */
+#define BCOM_FEC_RX_BD_ERRORS	(BCOM_FEC_RX_BD_LG | BCOM_FEC_RX_BD_NO | \
+		BCOM_FEC_RX_BD_CR | BCOM_FEC_RX_BD_OV | BCOM_FEC_RX_BD_TR)
 
 
 extern struct bcom_task *
