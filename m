From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] tools: bpf_asm: cleanup vlan extension related token
Date: Tue, 24 Mar 2015 23:19:24 +0100
Message-ID: <40b0db160a8e130431d2bb3de10089baf02bb3a1.1427230878.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48647 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbbCXWTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:19:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We now have K_VLANT, K_VLANP and K_VLANTPID. Clean them up into more
descriptive token, namely K_VLAN_TCI, K_VLAN_AVAIL and K_VLAN_TPID.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tools/net/bpf_exp.l |  8 ++++----
 tools/net/bpf_exp.y | 20 ++++++++++----------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/tools/net/bpf_exp.l b/tools/net/bpf_exp.l
index c83af3f..7cc72a3 100644
--- a/tools/net/bpf_exp.l
+++ b/tools/net/bpf_exp.l
@@ -90,10 +90,10 @@ extern void yyerror(const char *str);
 "#"?("hatype")	{ return K_HATYPE; }
 "#"?("rxhash")	{ return K_RXHASH; }
 "#"?("cpu")	{ return K_CPU; }
-"#"?("vlan_tci") { return K_VLANT; }
-"#"?("vlan_pr")	{ return K_VLANP; }
-"#"?("vlan_avail")	{ return K_VLANP; }
-"#"?("vlan_tpid")	{ return K_VLANTPID; }
+"#"?("vlan_tci")	{ return K_VLAN_TCI; }
+"#"?("vlan_pr")		{ return K_VLAN_AVAIL; }
+"#"?("vlan_avail")	{ return K_VLAN_AVAIL; }
+"#"?("vlan_tpid")	{ return K_VLAN_TPID; }
 "#"?("rand")	{ return K_RAND; }
 
 ":"		{ return ':'; }
diff --git a/tools/net/bpf_exp.y b/tools/net/bpf_exp.y
index f833274..e24eea1 100644
--- a/tools/net/bpf_exp.y
+++ b/tools/net/bpf_exp.y
@@ -56,7 +56,7 @@ static void bpf_set_jmp_label(char *label, enum jmp_type type);
 %token OP_LDXI
 
 %token K_PKT_LEN K_PROTO K_TYPE K_NLATTR K_NLATTR_NEST K_MARK K_QUEUE K_HATYPE
-%token K_RXHASH K_CPU K_IFIDX K_VLANT K_VLANP K_VLANTPID K_POFF K_RAND
+%token K_RXHASH K_CPU K_IFIDX K_VLAN_TCI K_VLAN_AVAIL K_VLAN_TPID K_POFF K_RAND
 
 %token ':' ',' '[' ']' '(' ')' 'x' 'a' '+' 'M' '*' '&' '#' '%'
 
@@ -155,10 +155,10 @@ ldb
 	| OP_LDB K_CPU {
 		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_CPU); }
-	| OP_LDB K_VLANT {
+	| OP_LDB K_VLAN_TCI {
 		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_VLAN_TAG); }
-	| OP_LDB K_VLANP {
+	| OP_LDB K_VLAN_AVAIL {
 		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_VLAN_TAG_PRESENT); }
 	| OP_LDB K_POFF {
@@ -167,7 +167,7 @@ ldb
 	| OP_LDB K_RAND {
 		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_RANDOM); }
-	| OP_LDB K_VLANTPID {
+	| OP_LDB K_VLAN_TPID {
 		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_VLAN_TPID); }
 	;
@@ -209,10 +209,10 @@ ldh
 	| OP_LDH K_CPU {
 		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_CPU); }
-	| OP_LDH K_VLANT {
+	| OP_LDH K_VLAN_TCI {
 		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_VLAN_TAG); }
-	| OP_LDH K_VLANP {
+	| OP_LDH K_VLAN_AVAIL {
 		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_VLAN_TAG_PRESENT); }
 	| OP_LDH K_POFF {
@@ -221,7 +221,7 @@ ldh
 	| OP_LDH K_RAND {
 		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_RANDOM); }
-	| OP_LDH K_VLANTPID {
+	| OP_LDH K_VLAN_TPID {
 		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_VLAN_TPID); }
 	;
@@ -268,10 +268,10 @@ ld
 	| OP_LD K_CPU {
 		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_CPU); }
-	| OP_LD K_VLANT {
+	| OP_LD K_VLAN_TCI {
 		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_VLAN_TAG); }
-	| OP_LD K_VLANP {
+	| OP_LD K_VLAN_AVAIL {
 		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_VLAN_TAG_PRESENT); }
 	| OP_LD K_POFF {
@@ -280,7 +280,7 @@ ld
 	| OP_LD K_RAND {
 		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_RANDOM); }
-	| OP_LD K_VLANTPID {
+	| OP_LD K_VLAN_TPID {
 		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_VLAN_TPID); }
 	| OP_LD 'M' '[' number ']' {
-- 
1.9.3
