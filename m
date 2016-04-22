From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH] cxgbi: fix uninitialized flowi6
Date: Fri, 22 Apr 2016 13:09:13 +0200
Message-ID: <89cb4d2647db3bc922c7067d421e983a271483ca.1461322282.git.jbenc@redhat.com>
Cc: netdev@vger.kernel.org,
	"James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
	"Martin K. Petersen" <martin.petersen@oracle.com>,
	Anish Bhatt <anish@chelsio.com>
To: linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip6_route_output looks into different fields in the passed flowi6 structure,
yet cxgbi passes garbage in nearly all those fields. Zero the structure out
first.

Fixes: fc8d0590d9142 ("libcxgbi: Add ipv6 api to driver")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/scsi/cxgbi/libcxgbi.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index f3bb7af4e984..ead83a24bcd1 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -688,6 +688,7 @@ static struct rt6_info *find_route_ipv6(const struct in6_addr *saddr,
 {
 	struct flowi6 fl;
 
+	memset(&fl, 0, sizeof(fl));
 	if (saddr)
 		memcpy(&fl.saddr, saddr, sizeof(struct in6_addr));
 	if (daddr)
-- 
1.8.3.1

