From: holger@eitzenberger.org
Subject: [patch 3/4] ipset: do session initialization once
Date: Tue, 18 Jan 2011 15:21:57 +0100
Message-ID: <20110118142247.991392505@eitzenberger.org>
References: <20110118142154.697547841@eitzenberger.org>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ipset-one-time-session-init.diff
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: ipset/src/ipset.c
===================================================================
--- ipset.orig/src/ipset.c	2011-01-05 12:05:31.000000000 +0100
+++ ipset/src/ipset.c	2011-01-05 12:07:02.000000000 +0100
@@ -431,14 +431,6 @@
 	const struct ipset_commands *command;
 	const struct ipset_type *type;
 
-	/* Initialize session */
-	if (session == NULL) {
-		session = ipset_session_init(printf);
-		if (session == NULL)
-			return exit_error(OTHER_PROBLEM,
-				"Cannot initialize ipset session, aborting.");
-	}
-
 	/* Commandline parsing, somewhat similar to that of 'ip' */
 
 	/* First: parse core options */
@@ -743,5 +735,10 @@
 	ipset_type_add(&ipset_hash_ipportnet0);
 	ipset_type_add(&ipset_list_set0);
 
+	session = ipset_session_init(printf);
+	if (session == NULL)
+		return exit_error(OTHER_PROBLEM,
+						  "Cannot initialize ipset session, aborting.");
+
 	return parse_commandline(argc, argv);
 }

-- 
