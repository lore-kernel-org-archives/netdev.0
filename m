From: Domen Puncer <domen.puncer@telargo.com>
Subject: [PATCH] ucc_geth_mii: fix __exit called from __init
Date: Fri, 20 Jul 2007 10:19:36 +0200
Message-ID: <20070720081936.GB4529@moe.telargo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org
To: leoli@freescale.com
Return-path: <linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

void __exit uec_mdio_exit(void) is called from
- static int __init ucc_geth_init(void)
- static void __exit ucc_geth_exit(void)

First one would make error path more than just an error.


Signed-off-by: Domen Puncer <domen.puncer@telargo.com>

---
 drivers/net/ucc_geth_mii.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: work-powerpc.git/drivers/net/ucc_geth_mii.c
===================================================================
--- work-powerpc.git.orig/drivers/net/ucc_geth_mii.c
+++ work-powerpc.git/drivers/net/ucc_geth_mii.c
@@ -272,7 +272,8 @@ int __init uec_mdio_init(void)
 	return of_register_platform_driver(&uec_mdio_driver);
 }
 
-void __exit uec_mdio_exit(void)
+/* called from __init ucc_geth_init, therefore can not be __exit */
+void uec_mdio_exit(void)
 {
 	of_unregister_platform_driver(&uec_mdio_driver);
 }
