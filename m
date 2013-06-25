From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next v5 6/6] vxlan: fdb: allow specifying multiple destinations for zero MAC
Date: Tue, 25 Jun 2013 16:01:56 +0300
Message-ID: <1372165316-17647-7-git-send-email-mike.rapoport@ravellosystems.com>
References: <1372165316-17647-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Stevens <dlstevens@us.ibm.com>,
	Thomas Graf <tgraf@suug.ch>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog110.obsmtp.com ([74.125.245.88]:50456 "HELO
	na3sys010aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751263Ab3FYNCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 09:02:32 -0400
Received: by mail-wi0-f172.google.com with SMTP id c10so759332wiw.17
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 06:02:31 -0700 (PDT)
In-Reply-To: <1372165316-17647-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The zero MAC entry in the fdb is used as default destination. With
multiple default destinations it is possible to use vxlan in
environments that disable multicast on the infrastructure level, e.g.
public clouds.

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 drivers/net/vxlan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index c182520..3e75f97 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -458,7 +458,8 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			notify = 1;
 		}
 		if ((flags & NLM_F_APPEND) &&
-		    is_multicast_ether_addr(f->eth_addr)) {
+		    (is_multicast_ether_addr(f->eth_addr) ||
+		     is_zero_ether_addr(f->eth_addr))) {
 			int rc = vxlan_fdb_append(f, ip, port, vni, ifindex);
 
 			if (rc < 0)
-- 
1.8.1.5
