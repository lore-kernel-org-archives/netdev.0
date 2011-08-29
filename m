From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/24] iucv: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:30 -0700
Message-ID: <a2e55a415105a8a68dfd2eb8ffe9db20a82edd52.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-s390@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ursula Braun <ursula.braun@de.ibm.com>, linux390@de.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/iucv/iucv.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/iucv/iucv.c b/net/iucv/iucv.c
index 403be43..5cf493d 100644
--- a/net/iucv/iucv.c
+++ b/net/iucv/iucv.c
@@ -1815,10 +1815,9 @@ static void iucv_external_interrupt(unsigned int ext_int_code,
 	}
 	BUG_ON(p->iptype  < 0x01 || p->iptype > 0x09);
 	work = kmalloc(sizeof(struct iucv_irq_list), GFP_ATOMIC);
-	if (!work) {
-		pr_warning("iucv_external_interrupt: out of memory\n");
+	if (!work)
 		return;
-	}
+
 	memcpy(&work->data, p, sizeof(work->data));
 	spin_lock(&iucv_queue_lock);
 	if (p->iptype == 0x01) {
-- 
1.7.6.405.gc1be0
