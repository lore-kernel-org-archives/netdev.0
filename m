From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/4] dcbnl: Use kmalloc_array() in dcbnl_build_peer_app()
Date: Sat, 28 Jan 2017 10:33:44 +0100
Message-ID: <ee60540c-0e30-4abf-2bf0-00ab5fe2aab8@users.sourceforge.net>
References: <ab981a3f-e73e-9bef-09c5-9c6d077aef00@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Pan Bian <bianpan2016@163.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <ab981a3f-e73e-9bef-09c5-9c6d077aef00@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 27 Jan 2017 22:30:09 +0100

* A multiplication for the size determination of a memory allocation
  indicated that an array data structure should be processed.
  Thus use the corresponding function "kmalloc_array".

  This issue was detected by using the Coccinelle software.

* Replace the specification of a data structure by a pointer dereference
  to make the corresponding size determination a bit safer according to
  the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/dcb/dcbnl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 3202d75329b5..76fd727e2eb4 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -990,7 +990,7 @@ static int dcbnl_build_peer_app(struct net_device *netdev, struct sk_buff* skb,
 	 */
 	err = ops->peer_getappinfo(netdev, &info, &app_count);
 	if (!err && app_count) {
-		table = kmalloc(sizeof(struct dcb_app) * app_count, GFP_KERNEL);
+		table = kmalloc_array(app_count, sizeof(*table), GFP_KERNEL);
 		if (!table)
 			return -ENOMEM;
 
-- 
2.11.0

