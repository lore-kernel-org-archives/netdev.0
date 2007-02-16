From: Vignesh Babu BM <vignesh.babu@wipro.com>
Subject: [KJ] [PATCH] is_power_of_2 in Chelsio
Date: Fri, 16 Feb 2007 17:34:21 +0530
Message-ID: <1171627461.6127.1.camel@wriver-t81fb058.linuxcoe>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: akpm@osdl.org, netdev@vger.kernel.org, jgarzik@pobox.com
To: Kernel Janitors List <kernel-janitors@lists.osdl.org>
Return-path: <kernel-janitors-bounces@lists.osdl.org>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

Replacing (n & (n-1)) in the context of power of 2 checks
with is_power_of_2


diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index c67f7d3..26ac0bb 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -42,6 +42,7 @@
 #include <linux/workqueue.h>
 #include <linux/proc_fs.h>
 #include <linux/rtnetlink.h>
+#include <linux/log2.h>
 #include <asm/uaccess.h>
 =

 #include "common.h"
@@ -1792,8 +1793,8 @@ static int cxgb_extension_ioctl(struct net_device *de=
v, void __user *useraddr)
 			return -EBUSY;
 		if (copy_from_user(&m, useraddr, sizeof(m)))
 			return -EFAULT;
-		if (!m.rx_pg_sz || (m.rx_pg_sz & (m.rx_pg_sz - 1)) ||
-			!m.tx_pg_sz || (m.tx_pg_sz & (m.tx_pg_sz - 1)))
+		if (!is_power_of_2(m.rx_pg_sz) ||
+			!is_power_of_2(m.tx_pg_sz))
 			return -EINVAL;	/* not power of 2 */
 		if (!(m.rx_pg_sz & 0x14000))
 			return -EINVAL;	/* not 16KB or 64KB */

-- =

Regards,  =

Vignesh Babu BM  =

_____________________________________________________________  =

"Why is it that every time I'm with you, makes me believe in magic?"
