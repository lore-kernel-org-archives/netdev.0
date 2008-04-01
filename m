From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 1/2] SCTP: fix wrong debug counting of datamsg
Date: Tue, 01 Apr 2008 11:41:15 +0800
Message-ID: <47F1AEDB.1080300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, lksctp-developers@lists.sourceforge.net,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62008 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752224AbYDADnQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 23:43:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should not count it if the allocation of this object
failed.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 net/sctp/chunk.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 4d3128f..099b0af 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -66,9 +66,10 @@ SCTP_STATIC struct sctp_datamsg *sctp_datamsg_new(gfp_t gfp)
 {
 	struct sctp_datamsg *msg;
 	msg = kmalloc(sizeof(struct sctp_datamsg), gfp);
-	if (msg)
+	if (msg) {
 		sctp_datamsg_init(msg);
-	SCTP_DBG_OBJCNT_INC(datamsg);
+		SCTP_DBG_OBJCNT_INC(datamsg);
+	}
 	return msg;
 }
 
-- 
1.5.4.rc3

