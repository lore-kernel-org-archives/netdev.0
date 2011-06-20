From: Jon Mason <jon.mason@myri.com>
Subject: [PATCH] myri10ge: 64bit slice stats
Date: Mon, 20 Jun 2011 13:46:36 -0500
Message-ID: <20110620184635.GA18577@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Andrew Gallatin <gallatin@myri.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:55489 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755245Ab1FTSqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 14:46:40 -0400
Received: by iwn6 with SMTP id 6so1420786iwn.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 11:46:39 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a potential issue of internal 32bit stats wrapping before
updating the external 64bit stats, thus leading to incorrect stats.
Since there is no hardware necessity for these counters to be 32bit,
change them to be 64bit to avoid this issue.

Patch suggested by Eric Dumazet.

Signed-off-by: Jon Mason <mason@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 04e10f4..2a51de1 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -170,12 +170,12 @@ struct myri10ge_rx_done {
 };
 
 struct myri10ge_slice_netstats {
-	unsigned long rx_packets;
-	unsigned long tx_packets;
-	unsigned long rx_bytes;
-	unsigned long tx_bytes;
-	unsigned long rx_dropped;
-	unsigned long tx_dropped;
+	u64 rx_packets;
+	u64 tx_packets;
+	u64 rx_bytes;
+	u64 tx_bytes;
+	u64 rx_dropped;
+	u64 tx_dropped;
 };
 
 struct myri10ge_slice_state {
-- 
1.7.5.4

