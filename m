From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 4/6] misc/ss: add missing fclose() calls
Date: Thu,  6 Aug 2015 14:24:34 +0200
Message-ID: <1438863876-1935-4-git-send-email-phil@nwl.cc>
References: <1438863876-1935-1-git-send-email-phil@nwl.cc>
 <1438863876-1935-2-git-send-email-phil@nwl.cc>
 <1438863876-1935-3-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:47709 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755143AbbHFMYi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2015 08:24:38 -0400
In-Reply-To: <1438863876-1935-3-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index e77655a..0c7c6d7 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3025,6 +3025,7 @@ static int packet_show_line(char *buf, const struct filter *f, int fam)
 static int packet_show(struct filter *f)
 {
 	FILE *fp;
+	int rc = 0;
 
 	if (!filter_af_get(f, AF_PACKET) || !(f->states & (1 << SS_CLOSE)))
 		return 0;
@@ -3036,9 +3037,10 @@ static int packet_show(struct filter *f)
 	if ((fp = net_packet_open()) == NULL)
 		return -1;
 	if (generic_record_read(fp, packet_show_line, f, AF_PACKET))
-		return -1;
+		rc = -1;
 
-	return 0;
+	fclose(fp);
+	return rc;
 }
 
 static int netlink_show_one(struct filter *f,
@@ -3215,6 +3217,7 @@ static int netlink_show(struct filter *f)
 		netlink_show_one(f, prot, pid, groups, 0, 0, 0, rq, wq, sk, cb);
 	}
 
+	fclose(fp);
 	return 0;
 }
 
-- 
2.1.2
