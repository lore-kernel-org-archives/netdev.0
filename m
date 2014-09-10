From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 4/5] iucv: Convert pr_warning to pr_warn
Date: Tue,  9 Sep 2014 21:17:31 -0700
Message-ID: <d976373ac5f17cb7716048d938a3ee1a5a10e6e2.1410322181.git.joe@perches.com>
References: <cover.1410322181.git.joe@perches.com>
Cc: Ursula Braun <ursula.braun@de.ibm.com>, linux390@de.ibm.com,
	"David S. Miller" <davem@davemloft.net>,
	linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1410322181.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the more common pr_warn.
Coalesce formats.
Realign arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/iucv/iucv.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/iucv/iucv.c b/net/iucv/iucv.c
index da78793..2a6a1fd 100644
--- a/net/iucv/iucv.c
+++ b/net/iucv/iucv.c
@@ -493,8 +493,8 @@ static void iucv_declare_cpu(void *data)
 			err = "Paging or storage error";
 			break;
 		}
-		pr_warning("Defining an interrupt buffer on CPU %i"
-			   " failed with 0x%02x (%s)\n", cpu, rc, err);
+		pr_warn("Defining an interrupt buffer on CPU %i failed with 0x%02x (%s)\n",
+			cpu, rc, err);
 		return;
 	}
 
@@ -1831,7 +1831,7 @@ static void iucv_external_interrupt(struct ext_code ext_code,
 	BUG_ON(p->iptype  < 0x01 || p->iptype > 0x09);
 	work = kmalloc(sizeof(struct iucv_irq_list), GFP_ATOMIC);
 	if (!work) {
-		pr_warning("iucv_external_interrupt: out of memory\n");
+		pr_warn("iucv_external_interrupt: out of memory\n");
 		return;
 	}
 	memcpy(&work->data, p, sizeof(work->data));
@@ -1974,8 +1974,7 @@ static int iucv_pm_restore(struct device *dev)
 	printk(KERN_WARNING "iucv_pm_restore %p\n", iucv_path_table);
 #endif
 	if ((iucv_pm_state != IUCV_PM_RESTORING) && iucv_path_table)
-		pr_warning("Suspending Linux did not completely close all IUCV "
-			"connections\n");
+		pr_warn("Suspending Linux did not completely close all IUCV connections\n");
 	iucv_pm_state = IUCV_PM_RESTORING;
 	if (cpumask_empty(&iucv_irq_cpumask)) {
 		rc = iucv_query_maxconn();
-- 
1.8.1.2.459.gbcd45b4.dirty
