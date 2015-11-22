From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH 01/13] net: mvneta: add configuration for MBUS windows access
 protection
Date: Sun, 22 Nov 2015 08:53:47 +0100
Message-ID: <1448178839-3541-2-git-send-email-mw@semihalf.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, andrew@lunn.ch, linux@arm.linux.org.uk,
 jason@lakedaemon.net, myair@marvell.com, jaz@semihalf.com,
 simon.guinot@sequanux.org, xswang@marvell.com, nadavh@marvell.com,
 alior@marvell.com, stable@vger.kernel.org, tn@semihalf.com,
 gregory.clement@free-electrons.com, nitroshift@yahoo.com, mw@semihalf.com,
 davem@davemloft.net, sebastian.hesselbarth@gmail.com
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1448178839-3541-1-git-send-email-mw@semihalf.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This commit adds missing configuration of MBUS windows access protection
in mvneta_conf_mbus_windows function - a dedicated variable for that
purpose remained there unused since v3.8 initial mvneta support. Because
of that the register contents were inherited from the bootloader.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
Cc: <stable@vger.kernel.org> # v3.8+
---
 drivers/net/ethernet/marvell/mvneta.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index e84c7f2..0f30aaa 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -62,6 +62,7 @@
 #define MVNETA_WIN_SIZE(w)                      (0x2204 + ((w) << 3))
 #define MVNETA_WIN_REMAP(w)                     (0x2280 + ((w) << 2))
 #define MVNETA_BASE_ADDR_ENABLE                 0x2290
+#define MVNETA_ACCESS_PROTECT_ENABLE		0x2294
 #define MVNETA_PORT_CONFIG                      0x2400
 #define      MVNETA_UNI_PROMISC_MODE            BIT(0)
 #define      MVNETA_DEF_RXQ(q)                  ((q) << 1)
@@ -3188,6 +3189,8 @@ static void mvneta_conf_mbus_windows(struct mvneta_port *pp,
 
 		win_enable &= ~(1 << i);
 		win_protect |= 3 << (2 * i);
+
+		mvreg_write(pp, MVNETA_ACCESS_PROTECT_ENABLE, win_protect);
 	}
 
 	mvreg_write(pp, MVNETA_BASE_ADDR_ENABLE, win_enable);
-- 
1.8.3.1
