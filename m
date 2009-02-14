From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 31/43] drivers/net/tokenring: fix sparse warning: cast
	truncates bits from const value
Date: Sat, 14 Feb 2009 22:46:24 +0100
Message-ID: <20090214214452.24377.31953.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f25.google.com ([209.85.220.25]:37910 "EHLO
	mail-fx0-f25.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbZBNVq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:46:29 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Use '__u16' instead of '__u8', this possibly fixes a bug.

Fix this sparse warnings:
  drivers/net/tokenring/smctr.c:4410:52: warning: cast truncates bits from constant value (100 becomes 0)
  drivers/net/tokenring/smctr.c:4415:52: warning: cast truncates bits from constant value (400 becomes 0)
  drivers/net/tokenring/smctr.c:4420:52: warning: cast truncates bits from constant value (800 becomes 0)
  drivers/net/tokenring/smctr.c:4425:52: warning: cast truncates bits from constant value (1000 becomes 0)
  drivers/net/tokenring/smctr.c:4430:52: warning: cast truncates bits from constant value (2000 becomes 0)
  drivers/net/tokenring/smctr.c:4435:52: warning: cast truncates bits from constant value (4000 becomes 0)
  drivers/net/tokenring/smctr.c:4440:52: warning: cast truncates bits from constant value (8000 becomes 0)

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---

Should the members be rearranged to avoid un-aligned access?

 drivers/net/tokenring/smctr.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tokenring/smctr.h b/drivers/net/tokenring/smctr.h
index 52df7dd..d98bc5b 100644
--- a/drivers/net/tokenring/smctr.h
+++ b/drivers/net/tokenring/smctr.h
@@ -977,7 +977,7 @@ typedef struct net_local {
 	__u8		monitor_state_ready;
 	__u16		ring_status;
 	__u8		ring_status_flags;
-	__u8		current_ring_status;
+	__u16		current_ring_status;
 	__u8		state;
 
 	__u8		join_state;

