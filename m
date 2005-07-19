From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 3/8][ATM]: [idt77252] use time_after() macro
Date: Tue, 19 Jul 2005 16:45:18 -0400
Message-ID: <200507192045.j6JKjHTD027197@ginger.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

[ATM]: [idt77252] use time_after() macro

  Signed-off-by: Marcelo Feitoza Parisi <marcelo@feitoza.com.br>
  Signed-off-by: Domen Puncer <domen@coderock.org>
  Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>


---
commit ac4755cc8eefb198945e76d4069184454c0819ce
tree e0dc319dca5c9e7f98c5d093c739db07a2707ac7
parent c4029a0d6294a1052353346235320a678add4f41
author chas williams <chas@relax.(none)> Tue, 19 Jul 2005 14:55:40 -0400
committer chas williams <chas@relax.(none)> Tue, 19 Jul 2005 14:55:40 -0400

 drivers/atm/idt77252.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -46,6 +46,7 @@ static char const rcsid[] =
 #include <linux/init.h>
 #include <linux/bitops.h>
 #include <linux/wait.h>
+#include <linux/jiffies.h>
 #include <asm/semaphore.h>
 #include <asm/io.h>
 #include <asm/uaccess.h>
@@ -780,7 +781,7 @@ push_on_scq(struct idt77252_dev *card, s
 	return 0;
 
 out:
-	if (jiffies - scq->trans_start > HZ) {
+	if (time_after(jiffies, scq->trans_start + HZ)) {
 		printk("%s: Error pushing TBD for %d.%d\n",
 		       card->name, vc->tx_vcc->vpi, vc->tx_vcc->vci);
 #ifdef CONFIG_ATM_IDT77252_DEBUG
