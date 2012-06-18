From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] tc: prio: Perform more strict check on priomap.
Date: Mon, 18 Jun 2012 14:33:38 +0800
Message-ID: <4FDECBC2.1090304@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51442 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751461Ab2FRGeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2012 02:34:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Since band number counts from zero thus band must be little than
opt.bands.
---
 tc/q_prio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/q_prio.c b/tc/q_prio.c
index 79b4fd0..bacc702 100644
--- a/tc/q_prio.c
+++ b/tc/q_prio.c
@@ -67,7 +67,7 @@ static int prio_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 				fprintf(stderr, "Illegal \"priomap\" element\n");
 				return -1;
 			}
-			if (band > opt.bands) {
+			if (band >= opt.bands) {
 				fprintf(stderr, "\"priomap\" element is out of bands\n");
 				return -1;
 			}
-- 
1.7.1
