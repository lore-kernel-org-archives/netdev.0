From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 PATCH 1/1] tc: don't ignore ok as an action branch
Date: Sat,  7 May 2016 09:39:36 -0400
Message-ID: <1462628376-10541-1-git-send-email-jhs@emojatatu.com>
Cc: phil@nwl.cc, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35434 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752179AbcEGNjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 09:39:53 -0400
Received: by mail-io0-f193.google.com with SMTP id u185so16763859iod.2
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 06:39:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

This is what used to happen before:

tc filter add dev tap1 parent ffff: protocol 0xfefe prio 10 \
     u32 match u32 0 0 flowid 1:16 \
     action ife decode allow mark ok

tc -s filter ls dev tap1 parent ffff:
filter protocol [65278] pref 10 u32
filter protocol [65278] pref 10 u32 fh 800: ht divisor 1
filter protocol [65278] pref 10 u32 fh 800::800 order 2048 key ht 800
bkt 0 flowid 1:16
  match 00000000/00000000 at 0
        action order 1: ife decode action pipe
         index 2 ref 1 bind 1 installed 4 sec used 4 sec
         type: 0x0
         Metadata: allow mark
        Action statistics:
        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
        backlog 0b 0p requeues 0

        action order 2: gact action pass
         random type none pass val 0
         index 1 ref 1 bind 1 installed 4 sec used 4 sec
        Action statistics:
        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
        backlog 0b 0p requeues 0

Note the extra action added at the end..

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_connmark.c | 3 ++-
 tc/m_csum.c     | 3 ++-
 tc/m_ife.c      | 3 ++-
 tc/m_mirred.c   | 3 ++-
 tc/m_nat.c      | 3 ++-
 tc/m_pedit.c    | 3 ++-
 tc/m_skbedit.c  | 3 ++-
 tc/m_vlan.c     | 3 ++-
 8 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/tc/m_connmark.c b/tc/m_connmark.c
index b1c7d3a..143d75d 100644
--- a/tc/m_connmark.c
+++ b/tc/m_connmark.c
@@ -99,7 +99,8 @@ parse_connmark(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 			sel.action = TC_ACT_UNSPEC;
 			argc--;
 			argv++;
-		} else if (matches(*argv, "pass") == 0) {
+		} else if (matches(*argv, "pass") == 0 ||
+			   matches(*argv, "ok") == 0) {
 			sel.action = TC_ACT_OK;
 			argc--;
 			argv++;
diff --git a/tc/m_csum.c b/tc/m_csum.c
index 36181fa..fb1183a 100644
--- a/tc/m_csum.c
+++ b/tc/m_csum.c
@@ -140,7 +140,8 @@ parse_csum(struct action_util *a, int *argc_p,
 			sel.action = TC_ACT_UNSPEC;
 			argc--;
 			argv++;
-		} else if (matches(*argv, "pass") == 0) {
+		} else if (matches(*argv, "pass") == 0 ||
+			   matches(*argv, "ok") == 0) {
 			sel.action = TC_ACT_OK;
 			argc--;
 			argv++;
diff --git a/tc/m_ife.c b/tc/m_ife.c
index 839e370..ed01ff7 100644
--- a/tc/m_ife.c
+++ b/tc/m_ife.c
@@ -167,7 +167,8 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 			p.action = TC_ACT_UNSPEC;
 			argc--;
 			argv++;
-		} else if (matches(*argv, "pass") == 0) {
+		} else if (matches(*argv, "pass") == 0 ||
+			   matches(*argv, "ok") == 0) {
 			p.action = TC_ACT_OK;
 			argc--;
 			argv++;
diff --git a/tc/m_mirred.c b/tc/m_mirred.c
index e7e69df..64aad4d 100644
--- a/tc/m_mirred.c
+++ b/tc/m_mirred.c
@@ -172,7 +172,8 @@ parse_egress(struct action_util *a, int *argc_p, char ***argv_p,
 		} else if (matches(*argv, "continue") == 0) {
 			p.action = TC_POLICE_UNSPEC;
 			NEXT_ARG();
-		} else if (matches(*argv, "pass") == 0) {
+		} else if (matches(*argv, "pass") == 0 ||
+			   matches(*argv, "ok") == 0) {
 			p.action = TC_POLICE_OK;
 			NEXT_ARG();
 		}
diff --git a/tc/m_nat.c b/tc/m_nat.c
index 4b90121..4d1b1ed 100644
--- a/tc/m_nat.c
+++ b/tc/m_nat.c
@@ -135,7 +135,8 @@ parse_nat(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, struct
 			sel.action = TC_ACT_UNSPEC;
 			argc--;
 			argv++;
-		} else if (matches(*argv, "pass") == 0) {
+		} else if (matches(*argv, "pass") == 0 ||
+			   matches(*argv, "ok") == 0) {
 			sel.action = TC_ACT_OK;
 			argc--;
 			argv++;
diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 2a94dfb..a539b68 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -495,7 +495,8 @@ parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, stru
 		} else if (matches(*argv, "continue") == 0) {
 			sel.sel.action = TC_ACT_UNSPEC;
 			NEXT_ARG();
-		} else if (matches(*argv, "pass") == 0) {
+		} else if (matches(*argv, "pass") == 0 ||
+			   matches(*argv, "ok") == 0) {
 			sel.sel.action = TC_ACT_OK;
 			NEXT_ARG();
 		}
diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
index 180b9cb..9ba288c 100644
--- a/tc/m_skbedit.c
+++ b/tc/m_skbedit.c
@@ -114,7 +114,8 @@ parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 		} else if (matches(*argv, "continue") == 0) {
 			sel.action = TC_ACT_UNSPEC;
 			NEXT_ARG();
-		} else if (matches(*argv, "pass") == 0) {
+		} else if (matches(*argv, "pass") == 0 ||
+			   matches(*argv, "ok") == 0) {
 			sel.action = TC_ACT_OK;
 			NEXT_ARG();
 		}
diff --git a/tc/m_vlan.c b/tc/m_vlan.c
index 3233d20..c268446 100644
--- a/tc/m_vlan.c
+++ b/tc/m_vlan.c
@@ -119,7 +119,8 @@ static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
 			parm.action = TC_ACT_UNSPEC;
 			argc--;
 			argv++;
-		} else if (matches(*argv, "pass") == 0) {
+		} else if (matches(*argv, "pass") == 0 ||
+			   matches(*argv, "ok") == 0) {
 			parm.action = TC_ACT_OK;
 			argc--;
 			argv++;
-- 
1.9.1
