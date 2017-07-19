From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH ethtool net] ethtool: fix the rx vs tx mixup in set channel message
Date: Tue, 18 Jul 2017 19:02:32 -0700
Message-ID: <20170719020232.19494-1-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:33877 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751969AbdGSCCu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 22:02:50 -0400
Received: by mail-pg0-f41.google.com with SMTP id 123so22274017pgj.1
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 19:02:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When set channels (ethtool -L) doesn't modify any settings
a message is printed which contains the current parameters:

# ethtool -L em1
no channel parameters changed, aborting
current values: tx 4 rx 1 other 0 combined 0

or

# ethtool -L em1 rx 4
rx unmodified, ignoring
no channel parameters changed, aborting
current values: tx 4 rx 1 other 0 combined 0

In this message, however, rx and tx values are swapped,
which can be confirmed running get:

# ethtool -l em1
...
Current hardware settings:
RX:		 4
TX:		 1
Other:		 0
Combined:	 0

Reorder the rx and tx names in the string thus keeping the order
in line with ethtool -l.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ethtool.c b/ethtool.c
index ad18704e7c5f..4fd340540303 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1995,7 +1995,7 @@ static int do_schannels(struct cmd_context *ctx)
 
 	if (!changed) {
 		fprintf(stderr, "no channel parameters changed, aborting\n");
-		fprintf(stderr, "current values: tx %u rx %u other %u"
+		fprintf(stderr, "current values: rx %u tx %u other %u"
 			" combined %u\n", echannels.rx_count,
 			echannels.tx_count, echannels.other_count,
 			echannels.combined_count);
-- 
2.11.0
