From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 10/18] ss: Make user_ent_hash_build_init local to user_ent_hash_build()
Date: Fri,  2 Dec 2016 11:39:54 +0100
Message-ID: <20161202104002.17310-11-phil@nwl.cc>
References: <20161202104002.17310-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35388 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934310AbcLBKlm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 05:41:42 -0500
In-Reply-To: <20161202104002.17310-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By having it statically defined, there is no need for it to be global.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 97fcfd4a85548..44386c82c7578 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -100,8 +100,6 @@ int show_bpf;
 int show_proc_ctx;
 int show_sock_ctx;
 int show_header = 1;
-/* If show_users & show_proc_ctx only do user_ent_hash_build() once */
-int user_ent_hash_build_init;
 int follow_events;
 int sctp_ino;
 
@@ -421,6 +419,7 @@ static void user_ent_hash_build(void)
 	char *pid_context;
 	char *sock_context;
 	const char *no_ctx = "unavailable";
+	static int user_ent_hash_build_init;
 
 	/* If show_users & show_proc_ctx set only do this once */
 	if (user_ent_hash_build_init != 0)
-- 
2.10.0
