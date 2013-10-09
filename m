From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 3/3] gianfar: Enable eTSEC-20 erratum w/a for P2020 Rev1
Date: Wed, 9 Oct 2013 20:20:42 +0300
Message-ID: <1381339242-32030-3-git-send-email-claudiu.manoil@freescale.com>
References: <1381339242-32030-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org
To: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1381339242-32030-1-git-send-email-claudiu.manoil@freescale.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

Enable workaround for P2020/P2010 erratum eTSEC 20,
"Excess delays when transmitting TOE=1 large frames".
The impact is that frames lager than 2500-bytes for which
TOE (i.e. TCP/IP hw accelerations like Tx csum) is enabled
may see excess delay before start of transmission.
This erratum was fixed in Rev 2.0.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 329a206..9fbe4dd 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -968,6 +968,9 @@ static void __gfar_detect_errata_85xx(struct gfar_private *priv)
 
 	if ((SVR_SOC_VER(svr) == SVR_8548) && (SVR_REV(svr) == 0x20))
 		priv->errata |= GFAR_ERRATA_12;
+	if (((SVR_SOC_VER(svr) == SVR_P2020) && (SVR_REV(svr) < 0x20)) ||
+	    ((SVR_SOC_VER(svr) == SVR_P2010) && (SVR_REV(svr) < 0x20)))
+		priv->errata |= GFAR_ERRATA_76; /* aka eTSEC 20 */
 }
 
 static void gfar_detect_errata(struct gfar_private *priv)
-- 
1.7.11.7
