From: Insu Yun <wuninsu@gmail.com>
Subject: [PATCH] rose: correct integer overflow check
Date: Wed, 17 Feb 2016 15:25:13 -0500
Message-ID: <1455740713-18262-1-git-send-email-wuninsu@gmail.com>
Cc: taesoo@gatech.edu, yeongjin.jang@gatech.edu, insu@gatech.edu,
	changwoo@gatech.edu, Insu Yun <wuninsu@gmail.com>
To: ralf@linux-mips.org, davem@davemloft.net,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since rose_ndevs is signed integer type,
it can be overflowed when it is negative.

Signed-off-by: Insu Yun <wuninsu@gmail.com>
---
 net/rose/af_rose.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 129d357..4f37fae 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1514,7 +1514,8 @@ static int __init rose_proto_init(void)
 	int i;
 	int rc;
 
-	if (rose_ndevs > 0x7FFFFFFF/sizeof(struct net_device *)) {
+	if (rose_ndevs < 0 ||
+	    rose_ndevs > 0x7FFFFFFF / sizeof(struct net_device *)) {
 		printk(KERN_ERR "ROSE: rose_proto_init - rose_ndevs parameter to large\n");
 		rc = -EINVAL;
 		goto out;
-- 
1.9.1

