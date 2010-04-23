From: Anton Vorontsov <avorontsov@mvista.com>
Subject: [PATCH 2/2] gianfar: Fix potential oops during OF address translation
Date: Fri, 23 Apr 2010 21:12:44 +0400
Message-ID: <20100423171244.GB2140@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
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

gianfar driver may pass NULL pointer to the of_translate_address(),
which may lead to a kernel oops. Fix this by using of_iomap(), which
is also much simpler and shorter.

Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>
---
 drivers/net/gianfar.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 080d1ce..df49af3 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -549,12 +549,8 @@ static int gfar_parse_group(struct device_node *np,
 		struct gfar_private *priv, const char *model)
 {
 	u32 *queue_mask;
-	u64 addr, size;
-
-	addr = of_translate_address(np,
-			of_get_address(np, 0, &size, NULL));
-	priv->gfargrp[priv->num_grps].regs = ioremap(addr, size);
 
+	priv->gfargrp[priv->num_grps].regs = of_iomap(np, 0);
 	if (!priv->gfargrp[priv->num_grps].regs)
 		return -ENOMEM;
 
-- 
1.7.0.5
