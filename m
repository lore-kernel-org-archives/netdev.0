From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH net] dql: Fix inconsistency between file mode and attr
 method.
Date: Sun, 15 Jan 2012 02:10:21 +0900
Message-ID: <20120115021021.1bb055da.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39098 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755657Ab2ANRKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 12:10:24 -0500
Received: by iagf6 with SMTP id f6so35641iag.19
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2012 09:10:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no store() method for inflight attribute in the
tx-<n>/byte_queue_limits sysfs directory.
So remove S_IWUSR bit.

Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
---
 net/core/net-sysfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index f3dbd4f..a1727cd 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -929,7 +929,7 @@ static ssize_t bql_show_inflight(struct netdev_queue *queue,
 }
 
 static struct netdev_queue_attribute bql_inflight_attribute =
-	__ATTR(inflight, S_IRUGO | S_IWUSR, bql_show_inflight, NULL);
+	__ATTR(inflight, S_IRUGO, bql_show_inflight, NULL);
 
 #define BQL_ATTR(NAME, FIELD)						\
 static ssize_t bql_show_ ## NAME(struct netdev_queue *queue,		\
-- 
1.7.3.4
