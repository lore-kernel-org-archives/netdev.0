From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/14] drivers/net/can/sja1000: Use printf extension %pR for struct resource
Date: Fri, 12 Nov 2010 13:37:59 -0800
Message-ID: <199bf35f52ea48bef79d4b40b504b0c85dca6fad.1289597644.git.joe@perches.com>
References: <cover.1289597644.git.joe@perches.com>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1289597644.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using %pR standardizes the struct resource output.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/can/sja1000/sja1000_of_platform.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index 5bfccfd..09c3e9d 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -107,17 +107,13 @@ static int __devinit sja1000_ofp_probe(struct platform_device *ofdev,
 	res_size = resource_size(&res);
 
 	if (!request_mem_region(res.start, res_size, DRV_NAME)) {
-		dev_err(&ofdev->dev, "couldn't request %#llx..%#llx\n",
-			(unsigned long long)res.start,
-			(unsigned long long)res.end);
+		dev_err(&ofdev->dev, "couldn't request %pR\n", &res);
 		return -EBUSY;
 	}
 
 	base = ioremap_nocache(res.start, res_size);
 	if (!base) {
-		dev_err(&ofdev->dev, "couldn't ioremap %#llx..%#llx\n",
-			(unsigned long long)res.start,
-			(unsigned long long)res.end);
+		dev_err(&ofdev->dev, "couldn't ioremap %pR\n", &res);
 		err = -ENOMEM;
 		goto exit_release_mem;
 	}
-- 
1.7.3.1.g432b3.dirty
