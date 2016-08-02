From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0750/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:42:41 +0800
Message-ID: <20160802114241.32062-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com, mst@redhat.com,
	pabeni@redhat.com, jasowang@redhat.com,
	makita.toshiaki@lab.ntt.co.jp, hannes@stressinduktion.org,
	daniel@iogearbox.net, chuansheng.liu@intel.com, baolex.ni@intel.com
To: richardcochran@gmail.com, f.fainelli@gmail.com,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/net/tun.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index e16487c..23bca00 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1673,9 +1673,9 @@ static ssize_t tun_show_group(struct device *dev, struct device_attribute *attr,
 		sprintf(buf, "-1\n");
 }
 
-static DEVICE_ATTR(tun_flags, 0444, tun_show_flags, NULL);
-static DEVICE_ATTR(owner, 0444, tun_show_owner, NULL);
-static DEVICE_ATTR(group, 0444, tun_show_group, NULL);
+static DEVICE_ATTR(tun_flags, S_IRUSR | S_IRGRP | S_IROTH, tun_show_flags, NULL);
+static DEVICE_ATTR(owner, S_IRUSR | S_IRGRP | S_IROTH, tun_show_owner, NULL);
+static DEVICE_ATTR(group, S_IRUSR | S_IRGRP | S_IROTH, tun_show_group, NULL);
 
 static struct attribute *tun_dev_attrs[] = {
 	&dev_attr_tun_flags.attr,
-- 
2.9.2
