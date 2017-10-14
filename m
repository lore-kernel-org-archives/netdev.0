From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] netrom: Delete an error message for a failed memory
 allocation in nr_proto_init()
Date: Sat, 14 Oct 2017 19:33:52 +0200
Message-ID: <3893dae9-a84f-b58c-689d-97ab6e4782fd@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        =?UTF-8?Q?Ralf_B=c3=a4chle?= <ralf@linux-mips.org>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 14 Oct 2017 18:48:18 +0200

Omit an extra message for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/netrom/af_netrom.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index ebf16f7f9089..568d6a148bf2 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1408,10 +1408,8 @@ static int __init nr_proto_init(void)
 	}
 
 	dev_nr = kzalloc(nr_ndevs * sizeof(struct net_device *), GFP_KERNEL);
-	if (dev_nr == NULL) {
-		printk(KERN_ERR "NET/ROM: nr_proto_init - unable to allocate device array\n");
+	if (!dev_nr)
 		return -1;
-	}
 
 	for (i = 0; i < nr_ndevs; i++) {
 		char name[IFNAMSIZ];
-- 
2.14.2

