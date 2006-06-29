From: "Bryan O'Sullivan" <bos@pathscale.com>
Subject: [PATCH 26 of 39] IB/ipath - check for valid
 LID and multicast LIDs
Date: Thu, 29 Jun 2006 14:41:17 -0700
Message-ID: <eef7f80215004f4cf854.1151617277@eng-12.pathscale.com>
References: <patchbomb.1151617251@eng-12.pathscale.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
In-Reply-To: <patchbomb.1151617251@eng-12.pathscale.com>
To: akpm@osdl.org,
	rdreier@cisco.com,
	mst@mellanox.co.il
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralph Campbell <ralph.campbell@qlogic.com>
Signed-off-by: Bryan O'Sullivan <bryan.osullivan@qlogic.com>

diff -r 4c581c37bb95 -r eef7f8021500 drivers/infiniband/hw/ipath/ipath_sysfs.c
--- a/drivers/infiniband/hw/ipath/ipath_sysfs.c	Thu Jun 29 14:33:26 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_sysfs.c	Thu Jun 29 14:33:26 2006 -0700
@@ -280,7 +280,7 @@ static ssize_t store_lid(struct device *
 	if (ret < 0)
 		goto invalid;
 
-	if (lid == 0 || lid >= 0xc000) {
+	if (lid == 0 || lid >= IPS_MULTICAST_LID_BASE) {
 		ret = -EINVAL;
 		goto invalid;
 	}
@@ -314,7 +314,7 @@ static ssize_t store_mlid(struct device 
 	int ret;
 
 	ret = ipath_parse_ushort(buf, &mlid);
-	if (ret < 0)
+	if (ret < 0 || mlid < IPS_MULTICAST_LID_BASE)
 		goto invalid;
 
 	unit = dd->ipath_unit;
