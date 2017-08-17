From: Colin King <colin.king@canonical.com>
Subject: [PATCH] irda: do not leak initialized list.dev to userspace
Date: Thu, 17 Aug 2017 23:14:58 +0100
Message-ID: <20170817221458.27040-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Samuel Ortiz <samuel@sortiz.org>,
        "David S . Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

list.dev has not been initialized and so the copy_to_user is copying
data from the stack back to user space which is a potential
information leak. Fix this ensuring all of list is initialized to
zero.

Detected by CoverityScan, CID#1357894 ("Uninitialized scalar variable")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/irda/af_irda.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 2e6990f8b80b..23fa7c8b09a5 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -2213,7 +2213,7 @@ static int irda_getsockopt(struct socket *sock, int level, int optname,
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self = irda_sk(sk);
-	struct irda_device_list list;
+	struct irda_device_list list = { 0 };
 	struct irda_device_info *discoveries;
 	struct irda_ias_set *	ias_opt;	/* IAS get/query params */
 	struct ias_object *	ias_obj;	/* Object in IAS */
-- 
2.11.0
