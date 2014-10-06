From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 1/1] discourage use of direct policer interface
Date: Mon,  6 Oct 2014 07:41:21 -0400
Message-ID: <1412595681-7302-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, Jamal Hadi Salim <hadi@mojatatu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:59675 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbaJFLlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 07:41:32 -0400
Received: by mail-ie0-f180.google.com with SMTP id x19so3004808ier.25
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 04:41:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/f_basic.c  |    3 ++-
 tc/f_bpf.c    |    5 +++--
 tc/f_cgroup.c |    4 ++--
 tc/f_flow.c   |    2 +-
 tc/f_fw.c     |    4 ++--
 tc/f_rsvp.c   |    4 ++--
 tc/f_u32.c    |    2 +-
 7 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/tc/f_basic.c b/tc/f_basic.c
index 67d26ec..1c33ca3 100644
--- a/tc/f_basic.c
+++ b/tc/f_basic.c
@@ -27,11 +27,12 @@
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... basic [ match EMATCH_TREE ] [ police POLICE_SPEC ]\n");
+	fprintf(stderr, "Usage: ... basic [ match EMATCH_TREE ] \n");
 	fprintf(stderr, "                 [ action ACTION_SPEC ] [ classid CLASSID ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: SELECTOR := SAMPLE SAMPLE ...\n");
 	fprintf(stderr, "       FILTERID := X:Y:Z\n");
+	fprintf(stderr, "       ACTION_SPEC := ... look at individual actions\n");
 	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
 }
 
diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index 8f1593c..48635a7 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -34,13 +34,14 @@ static void explain(void)
 	fprintf(stderr, " [inline]:     run bytecode BPF_BYTECODE\n");
 	fprintf(stderr, " [from file]:  run bytecode-file FILE\n");
 	fprintf(stderr, "\n");
-	fprintf(stderr, "               [ police POLICE_SPEC ] [ action ACTION_SPEC ]\n");
+	fprintf(stderr, "               [ action ACTION_SPEC ]\n");
 	fprintf(stderr, "               [ classid CLASSID ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where BPF_BYTECODE := \'s,c t f k,c t f k,c t f k,...\'\n");
 	fprintf(stderr, "      c,t,f,k and s are decimals; s denotes number of 4-tuples\n");
 	fprintf(stderr, "Where FILE points to a file containing the BPF_BYTECODE string\n");
-	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
+	fprintf(stderr, "\nACTION_SPEC := ... look at individual actions\n");
+	fprintf(stderr, "NOTE: CLASSID is parsed as hexadecimal input.\n");
 }
 
 static int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
diff --git a/tc/f_cgroup.c b/tc/f_cgroup.c
index 4a4026e..53f7406 100644
--- a/tc/f_cgroup.c
+++ b/tc/f_cgroup.c
@@ -18,8 +18,8 @@
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... cgroup [ match EMATCH_TREE ] [ police POLICE_SPEC ]\n");
-	fprintf(stderr, "                 [ action ACTION_SPEC ]\n");
+	fprintf(stderr, "Usage: ... cgroup [ match EMATCH_TREE ]\n");
+	fprintf(stderr, "                  [ action ACTION_SPEC ]\n");
 }
 
 static int cgroup_parse_opt(struct filter_util *qu, char *handle,
diff --git a/tc/f_flow.c b/tc/f_flow.c
index 7d4bb7a..b454a65 100644
--- a/tc/f_flow.c
+++ b/tc/f_flow.c
@@ -27,7 +27,7 @@ static void explain(void)
 " [hashing mode]: hash keys KEY-LIST ... [ perturb SECS ]\n"
 "\n"
 "                 [ divisor NUM ] [ baseclass ID ] [ match EMATCH_TREE ]\n"
-"                 [ police POLICE_SPEC ] [ action ACTION_SPEC ]\n"
+"                 [ action ACTION_SPEC ]\n"
 "\n"
 "KEY-LIST := [ KEY-LIST , ] KEY\n"
 "KEY      := [ src | dst | proto | proto-src | proto-dst | iif | priority | \n"
diff --git a/tc/f_fw.c b/tc/f_fw.c
index 161e2f7..165f489 100644
--- a/tc/f_fw.c
+++ b/tc/f_fw.c
@@ -25,8 +25,8 @@
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... fw [ classid CLASSID ] [ police POLICE_SPEC ]\n");
-	fprintf(stderr, "       POLICE_SPEC := ... look at TBF\n");
+	fprintf(stderr, "Usage: ... fw [ classid CLASSID ] [ action ACTION_SPEC ]\n");
+	fprintf(stderr, "       ACTION_SPEC := ... look at individual actions\n");
 	fprintf(stderr, "       CLASSID := X:Y\n");
 	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
 }
diff --git a/tc/f_rsvp.c b/tc/f_rsvp.c
index 14f24b1..cb7b8fb 100644
--- a/tc/f_rsvp.c
+++ b/tc/f_rsvp.c
@@ -28,11 +28,11 @@ static void explain(void)
 {
 	fprintf(stderr, "Usage: ... rsvp ipproto PROTOCOL session DST[/PORT | GPI ]\n");
 	fprintf(stderr, "                [ sender SRC[/PORT | GPI ]\n");
-	fprintf(stderr, "                [ classid CLASSID ] [ police POLICE_SPEC ]\n");
+	fprintf(stderr, "                [ classid CLASSID ] [ action ACTION_SPEC ]\n");
 	fprintf(stderr, "                [ tunnelid ID ] [ tunnel ID skip NUMBER ]\n");
 	fprintf(stderr, "Where: GPI := { flowlabel NUMBER | spi/ah SPI | spi/esp SPI |\n");
 	fprintf(stderr, "                u{8|16|32} NUMBER mask MASK at OFFSET}\n");
-	fprintf(stderr, "       POLICE_SPEC := ... look at TBF\n");
+	fprintf(stderr, "       ACTION_SPEC := ... look at individual actions\n");
 	fprintf(stderr, "       FILTERID := X:Y\n");
 	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
 }
diff --git a/tc/f_u32.c b/tc/f_u32.c
index f2a862d..80a5097 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -32,7 +32,7 @@ static void explain(void)
 {
 	fprintf(stderr, "Usage: ... u32 [ match SELECTOR ... ] [ link HTID ]"
 		" [ classid CLASSID ]\n");
-	fprintf(stderr, "               [ police POLICE_SPEC ]"
+	fprintf(stderr, "               [ action ACTION_SPEC ]"
 		" [ offset OFFSET_SPEC ]\n");
 	fprintf(stderr, "               [ ht HTID ] [ hashkey HASHKEY_SPEC ]\n");
 	fprintf(stderr, "               [ sample SAMPLE ]\n");
-- 
1.7.9.5
