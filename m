From: Levente Kurusa <levex@linux.com>
Subject: [PATCH 20/38] net: iucv: add missing put_device call
Date: Thu, 19 Dec 2013 16:03:31 +0100
Message-ID: <1387465429-3568-21-git-send-email-levex@linux.com>
References: <1387465429-3568-2-git-send-email-levex@linux.com>
Cc: Levente Kurusa <levex@linux.com>,
	Ursula Braun <ursula.braun@de.ibm.com>, linux390@de.ibm.com,
	"David S. Miller" <davem@davemloft.net>,
	linux-s390@vger.kernel.org, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387465429-3568-2-git-send-email-levex@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is required so that we give up the last reference to the device.

Signed-off-by: Levente Kurusa <levex@linux.com>
---
 net/iucv/af_iucv.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 168aff5..0096206 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -2377,8 +2377,10 @@ static int afiucv_iucv_init(void)
 	af_iucv_dev->release = (void (*)(struct device *))kfree;
 	af_iucv_dev->driver = &af_iucv_driver;
 	err = device_register(af_iucv_dev);
-	if (err)
+	if (err) {
+		put_device(af_iucv_dev);
 		goto out_driver;
+	}
 	return 0;
 
 out_driver:
-- 
1.8.3.1
