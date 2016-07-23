From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 3/4] tc: use action_a2n() everywhere
Date: Sat, 23 Jul 2016 13:28:09 +0200
Message-ID: <1469273290-18539-4-git-send-email-phil@nwl.cc>
References: <1469273290-18539-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46537 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751260AbcGWL2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:28:23 -0400
In-Reply-To: <1469273290-18539-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_bpf.c      | 22 ++--------------------
 tc/m_connmark.c | 27 ++-------------------------
 tc/m_csum.c     | 27 ++-------------------------
 tc/m_gact.c     | 17 ++++-------------
 tc/m_ife.c      | 27 ++-------------------------
 tc/m_mirred.c   | 25 +++----------------------
 tc/m_nat.c      | 27 ++-------------------------
 tc/m_pedit.c    | 22 ++--------------------
 tc/m_police.c   | 32 ++------------------------------
 tc/m_simple.c   | 27 ++-------------------------
 tc/m_skbedit.c  | 22 ++--------------------
 tc/m_vlan.c     | 27 ++-------------------------
 12 files changed, 27 insertions(+), 275 deletions(-)

diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index 20da11d07adae..275634e78b093 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -104,26 +104,8 @@ opt_bpf:
 		NEXT_ARG_FWD();
 	}
 
-	if (argc) {
-		if (matches(*argv, "reclassify") == 0) {
-			parm.action = TC_ACT_RECLASSIFY;
-			NEXT_ARG_FWD();
-		} else if (matches(*argv, "pipe") == 0) {
-			parm.action = TC_ACT_PIPE;
-			NEXT_ARG_FWD();
-		} else if (matches(*argv, "drop") == 0 ||
-			   matches(*argv, "shot") == 0) {
-			parm.action = TC_ACT_SHOT;
-			NEXT_ARG_FWD();
-		} else if (matches(*argv, "continue") == 0) {
-			parm.action = TC_ACT_UNSPEC;
-			NEXT_ARG_FWD();
-		} else if (matches(*argv, "pass") == 0 ||
-			   matches(*argv, "ok") == 0) {
-			parm.action = TC_ACT_OK;
-			NEXT_ARG_FWD();
-		}
-	}
+	if (argc && !action_a2n(*argv, &parm.action, false))
+		NEXT_ARG_FWD();
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
diff --git a/tc/m_connmark.c b/tc/m_connmark.c
index 143d75de66b8b..20f98e4fd63a8 100644
--- a/tc/m_connmark.c
+++ b/tc/m_connmark.c
@@ -81,31 +81,8 @@ parse_connmark(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 	}
 
 	sel.action = TC_ACT_PIPE;
-	if (argc) {
-		if (matches(*argv, "reclassify") == 0) {
-			sel.action = TC_ACT_RECLASSIFY;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "pipe") == 0) {
-			sel.action = TC_ACT_PIPE;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "drop") == 0 ||
-			   matches(*argv, "shot") == 0) {
-			sel.action = TC_ACT_SHOT;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "continue") == 0) {
-			sel.action = TC_ACT_UNSPEC;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "pass") == 0 ||
-			   matches(*argv, "ok") == 0) {
-			sel.action = TC_ACT_OK;
-			argc--;
-			argv++;
-		}
-	}
+	if (argc && !action_a2n(*argv, &sel.action, false))
+		NEXT_ARG_FWD();
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
diff --git a/tc/m_csum.c b/tc/m_csum.c
index 047986efd90c5..db7eed3adfeaf 100644
--- a/tc/m_csum.c
+++ b/tc/m_csum.c
@@ -120,31 +120,8 @@ parse_csum(struct action_util *a, int *argc_p,
 		return -1;
 	}
 
-	if (argc) {
-		if (matches(*argv, "reclassify") == 0) {
-			sel.action = TC_ACT_RECLASSIFY;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "pipe") == 0) {
-			sel.action = TC_ACT_PIPE;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "drop") == 0 ||
-			matches(*argv, "shot") == 0) {
-			sel.action = TC_ACT_SHOT;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "continue") == 0) {
-			sel.action = TC_ACT_UNSPEC;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "pass") == 0 ||
-			   matches(*argv, "ok") == 0) {
-			sel.action = TC_ACT_OK;
-			argc--;
-			argv++;
-		}
-	}
+	if (argc && !action_a2n(*argv, &sel.action, false))
+		NEXT_ARG_FWD();
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
diff --git a/tc/m_gact.c b/tc/m_gact.c
index ea2c9ec825146..9f31fdd324fdc 100644
--- a/tc/m_gact.c
+++ b/tc/m_gact.c
@@ -71,22 +71,13 @@ usage(void)
 static int
 get_act(char ***argv_p)
 {
-	char **argv = *argv_p;
+	int n;
 
-	if (matches(*argv, "reclassify") == 0) {
-		return TC_ACT_RECLASSIFY;
-	} else if (matches(*argv, "drop") == 0 || matches(*argv, "shot") == 0) {
-		return TC_ACT_SHOT;
-	} else if (matches(*argv, "continue") == 0) {
-		return TC_ACT_UNSPEC;
-	} else if (matches(*argv, "pipe") == 0) {
-		return TC_ACT_PIPE;
-	} else if (matches(*argv, "pass") == 0 || matches(*argv, "ok") == 0)  {
-		return TC_ACT_OK;
-	} else {
-		fprintf(stderr, "bad action type %s\n", *argv);
+	if (!action_a2n(**argv_p, &n, false)) {
+		fprintf(stderr, "bad action type %s\n", **argv_p);
 		return -10;
 	}
+	return n;
 }
 
 static int
diff --git a/tc/m_ife.c b/tc/m_ife.c
index eaab1cc85513d..5eee544b71b82 100644
--- a/tc/m_ife.c
+++ b/tc/m_ife.c
@@ -146,31 +146,8 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 		argv++;
 	}
 
-	if (argc) {
-		if (matches(*argv, "reclassify") == 0) {
-			p.action = TC_ACT_RECLASSIFY;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "pipe") == 0) {
-			p.action = TC_ACT_PIPE;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "drop") == 0 ||
-			   matches(*argv, "shot") == 0) {
-			p.action = TC_ACT_SHOT;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "continue") == 0) {
-			p.action = TC_ACT_UNSPEC;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "pass") == 0 ||
-			   matches(*argv, "ok") == 0) {
-			p.action = TC_ACT_OK;
-			argc--;
-			argv++;
-		}
-	}
+	if (argc && !action_a2n(*argv, &p.action, false))
+		NEXT_ARG_FWD();
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
diff --git a/tc/m_mirred.c b/tc/m_mirred.c
index 0066905ace553..61a84f575cf12 100644
--- a/tc/m_mirred.c
+++ b/tc/m_mirred.c
@@ -154,28 +154,9 @@ parse_egress(struct action_util *a, int *argc_p, char ***argv_p,
 	}
 
 
-	if (argc && p.eaction == TCA_EGRESS_MIRROR) {
-
-		if (matches(*argv, "reclassify") == 0) {
-			p.action = TC_POLICE_RECLASSIFY;
-			NEXT_ARG();
-		} else if (matches(*argv, "pipe") == 0) {
-			p.action = TC_POLICE_PIPE;
-			NEXT_ARG();
-		} else if (matches(*argv, "drop") == 0 ||
-			   matches(*argv, "shot") == 0) {
-			p.action = TC_POLICE_SHOT;
-			NEXT_ARG();
-		} else if (matches(*argv, "continue") == 0) {
-			p.action = TC_POLICE_UNSPEC;
-			NEXT_ARG();
-		} else if (matches(*argv, "pass") == 0 ||
-			   matches(*argv, "ok") == 0) {
-			p.action = TC_POLICE_OK;
-			NEXT_ARG();
-		}
-
-	}
+	if (argc && p.eaction == TCA_EGRESS_MIRROR
+	    && !action_a2n(*argv, &p.action, false))
+		NEXT_ARG();
 
 	if (argc) {
 		if (iok && matches(*argv, "index") == 0) {
diff --git a/tc/m_nat.c b/tc/m_nat.c
index 839fb8a056a40..52bafa79e1b73 100644
--- a/tc/m_nat.c
+++ b/tc/m_nat.c
@@ -115,31 +115,8 @@ parse_nat(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, struct
 		return -1;
 	}
 
-	if (argc) {
-		if (matches(*argv, "reclassify") == 0) {
-			sel.action = TC_ACT_RECLASSIFY;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "pipe") == 0) {
-			sel.action = TC_ACT_PIPE;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "drop") == 0 ||
-			matches(*argv, "shot") == 0) {
-			sel.action = TC_ACT_SHOT;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "continue") == 0) {
-			sel.action = TC_ACT_UNSPEC;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "pass") == 0 ||
-			   matches(*argv, "ok") == 0) {
-			sel.action = TC_ACT_OK;
-			argc--;
-			argv++;
-		}
-	}
+	if (argc && !action_a2n(*argv, &sel.action, false))
+		NEXT_ARG_FWD();
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 35879b7fb72e2..c28f2610aa011 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -481,26 +481,8 @@ int parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 		return -1;
 	}
 
-	if (argc) {
-		if (matches(*argv, "reclassify") == 0) {
-			sel.sel.action = TC_ACT_RECLASSIFY;
-			NEXT_ARG();
-		} else if (matches(*argv, "pipe") == 0) {
-			sel.sel.action = TC_ACT_PIPE;
-			NEXT_ARG();
-		} else if (matches(*argv, "drop") == 0 ||
-			   matches(*argv, "shot") == 0) {
-			sel.sel.action = TC_ACT_SHOT;
-			NEXT_ARG();
-		} else if (matches(*argv, "continue") == 0) {
-			sel.sel.action = TC_ACT_UNSPEC;
-			NEXT_ARG();
-		} else if (matches(*argv, "pass") == 0 ||
-			   matches(*argv, "ok") == 0) {
-			sel.sel.action = TC_ACT_OK;
-			NEXT_ARG();
-		}
-	}
+	if (argc && !action_a2n(*argv, &sel.sel.action, false))
+		NEXT_ARG();
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
diff --git a/tc/m_police.c b/tc/m_police.c
index 9ae25f2888202..3ba580e4fc225 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -71,34 +71,6 @@ static const char *police_action_n2a(int action, char *buf, int len)
 	}
 }
 
-static int police_action_a2n(const char *arg, int *result)
-{
-	int res;
-
-	if (matches(arg, "continue") == 0)
-		res = -1;
-	else if (matches(arg, "drop") == 0)
-		res = TC_POLICE_SHOT;
-	else if (matches(arg, "shot") == 0)
-		res = TC_POLICE_SHOT;
-	else if (matches(arg, "pass") == 0)
-		res = TC_POLICE_OK;
-	else if (strcmp(arg, "ok") == 0)
-		res = TC_POLICE_OK;
-	else if (matches(arg, "reclassify") == 0)
-		res = TC_POLICE_RECLASSIFY;
-	else if (matches(arg, "pipe") == 0)
-		res = TC_POLICE_PIPE;
-	else {
-		char dummy;
-
-		if (sscanf(arg, "%d%c", &res, &dummy) != 1)
-			return -1;
-	}
-	*result = res;
-	return 0;
-}
-
 static int get_police_result(int *action, int *result, char *arg)
 {
 	char *p = strchr(arg, '/');
@@ -106,7 +78,7 @@ static int get_police_result(int *action, int *result, char *arg)
 	if (p)
 		*p = 0;
 
-	if (police_action_a2n(arg, action)) {
+	if (action_a2n(arg, action, true)) {
 		if (p)
 			*p = '/';
 		return -1;
@@ -114,7 +86,7 @@ static int get_police_result(int *action, int *result, char *arg)
 
 	if (p) {
 		*p = '/';
-		if (police_action_a2n(p+1, result))
+		if (action_a2n(p+1, result, true))
 			return -1;
 	}
 	return 0;
diff --git a/tc/m_simple.c b/tc/m_simple.c
index 27b3e5e406d05..732eaf1eb6d94 100644
--- a/tc/m_simple.c
+++ b/tc/m_simple.c
@@ -120,31 +120,8 @@ parse_simple(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 		}
 	}
 
-	if (argc) {
-		if (matches(*argv, "reclassify") == 0) {
-			sel.action = TC_ACT_RECLASSIFY;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "pipe") == 0) {
-			sel.action = TC_ACT_PIPE;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "drop") == 0 ||
-			   matches(*argv, "shot") == 0) {
-			sel.action = TC_ACT_SHOT;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "continue") == 0) {
-			sel.action = TC_ACT_UNSPEC;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "pass") == 0 ||
-			   matches(*argv, "ok") == 0) {
-			sel.action = TC_ACT_OK;
-			argc--;
-			argv++;
-		}
-	}
+	if (argc && !action_a2n(*argv, &sel.action, false))
+		NEXT_ARG_FWD();
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
index 9ba288c075e08..eca6a8ac73899 100644
--- a/tc/m_skbedit.c
+++ b/tc/m_skbedit.c
@@ -100,26 +100,8 @@ parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 	}
 
 	sel.action = TC_ACT_PIPE;
-	if (argc) {
-		if (matches(*argv, "reclassify") == 0) {
-			sel.action = TC_ACT_RECLASSIFY;
-			NEXT_ARG();
-		} else if (matches(*argv, "pipe") == 0) {
-			sel.action = TC_ACT_PIPE;
-			NEXT_ARG();
-		} else if (matches(*argv, "drop") == 0 ||
-			matches(*argv, "shot") == 0) {
-			sel.action = TC_ACT_SHOT;
-			NEXT_ARG();
-		} else if (matches(*argv, "continue") == 0) {
-			sel.action = TC_ACT_UNSPEC;
-			NEXT_ARG();
-		} else if (matches(*argv, "pass") == 0 ||
-			   matches(*argv, "ok") == 0) {
-			sel.action = TC_ACT_OK;
-			NEXT_ARG();
-		}
-	}
+	if (argc && !action_a2n(*argv, &sel.action, false))
+		NEXT_ARG();
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
diff --git a/tc/m_vlan.c b/tc/m_vlan.c
index c2684461b616a..82311dd692bca 100644
--- a/tc/m_vlan.c
+++ b/tc/m_vlan.c
@@ -101,31 +101,8 @@ static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
 	}
 
 	parm.action = TC_ACT_PIPE;
-	if (argc) {
-		if (matches(*argv, "reclassify") == 0) {
-			parm.action = TC_ACT_RECLASSIFY;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "pipe") == 0) {
-			parm.action = TC_ACT_PIPE;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "drop") == 0 ||
-			   matches(*argv, "shot") == 0) {
-			parm.action = TC_ACT_SHOT;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "continue") == 0) {
-			parm.action = TC_ACT_UNSPEC;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "pass") == 0 ||
-			   matches(*argv, "ok") == 0) {
-			parm.action = TC_ACT_OK;
-			argc--;
-			argv++;
-		}
-	}
+	if (argc && !action_a2n(*argv, &parm.action, false))
+		NEXT_ARG_FWD();
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
-- 
2.8.2
