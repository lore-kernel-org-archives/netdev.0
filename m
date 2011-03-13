From: dbaluta@ixiacom.com
Subject: [PATCH] af_unix: update locking comment
Date: Sun, 13 Mar 2011 22:11:46 +0200
Message-ID: <1300047106-8545-1-git-send-email-dbaluta@ixiacom.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Daniel Baluta <daniel.baluta@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36983 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756183Ab1CMULz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 16:11:55 -0400
Received: by fxm17 with SMTP id 17so2351551fxm.19
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2011 13:11:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Baluta <daniel.baluta@gmail.com>

We latch our state using a spinlock not a r/w kind of lock.

Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
---
 net/unix/af_unix.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index de87018..ef70615 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1124,7 +1124,7 @@ restart:
 
 	/* Latch our state.
 
-	   It is tricky place. We need to grab write lock and cannot
+	   It is tricky place. We need to grab our state lock and cannot
 	   drop lock on peer. It is dangerous because deadlock is
 	   possible. Connect to self case and simultaneous
 	   attempt to connect are eliminated by checking socket
-- 
1.7.1

