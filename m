From: jamal <hadi@cyberus.ca>
Subject: [IPROUTE2 PATCH][U32] Fix missing class/flowid oddity
Date: Thu, 07 Dec 2006 11:07:07 -0500
Message-ID: <1165507627.3739.25.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-KpunSdDXcdtRJP5Jjd6F"
Cc: Marco Berizzi <pupilla@hotmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:61277 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032362AbWLGQHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 11:07:11 -0500
Received: by ug-out-1314.google.com with SMTP id 44so503413uga
        for <netdev@vger.kernel.org>; Thu, 07 Dec 2006 08:07:10 -0800 (PST)
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-KpunSdDXcdtRJP5Jjd6F
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



--=-KpunSdDXcdtRJP5Jjd6F
Content-Disposition: attachment; filename=ipr-fact1
Content-Type: text/plain; name=ipr-fact1; charset=us-ascii
Content-Transfer-Encoding: 7bit

[U32] Fix missing class/flowid oddity
When an action or policer is specified but not a classid/flowid, the
syntax accepts it but the kernel never really hits it.
This has been a long standing problem, but thanks to the persistence
of Marco Berizzi <pupilla@hotmail.com> I broke down and fixed it.

Signed-off-by: J Hadi Salim <hadi@cyberus.ca>

---
commit e2d2d34581e80363dfa29095e9e61d75f52963a1
tree fae21f558b325de873caf5d0559694063cd2b3c3
parent 32d6a748acb678ab4acb0c21844a0b03475baca1
author Jamal Hadi Salim <hadi@cyberus.ca> Thu, 07 Dec 2006 09:02:11 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Thu, 07 Dec 2006 09:02:11 -0500

 tc/f_u32.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/tc/f_u32.c b/tc/f_u32.c
index aa83ba0..fe31ec0 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -779,7 +779,7 @@ static int u32_parse_opt(struct filter_util *qu, char *handle, int argc, char **
 	} sel;
 	struct tcmsg *t = NLMSG_DATA(n);
 	struct rtattr *tail;
-	int sel_ok = 0;
+	int sel_ok = 0, terminal_ok = 0;
 	int sample_ok = 0;
 	__u32 htid = 0;
 	__u32 order = 0;
@@ -924,6 +924,7 @@ static int u32_parse_opt(struct filter_util *qu, char *handle, int argc, char **
 				fprintf(stderr, "Illegal \"action\"\n");
 				return -1;
 			}
+			terminal_ok++;
 			continue;
 
 		} else if (matches(*argv, "police") == 0) {
@@ -932,6 +933,7 @@ static int u32_parse_opt(struct filter_util *qu, char *handle, int argc, char **
 				fprintf(stderr, "Illegal \"police\"\n");
 				return -1;
 			}
+			terminal_ok++;
 			continue;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
@@ -944,6 +946,10 @@ static int u32_parse_opt(struct filter_util *qu, char *handle, int argc, char **
 		argc--; argv++;
 	}
 
+	/* We dont necessarily need class/flowids */
+	if (terminal_ok) 
+		sel.sel.flags |= TC_U32_TERMINAL;
+	
 	if (order) {
 		if (TC_U32_NODE(t->tcm_handle) && order != TC_U32_NODE(t->tcm_handle)) {
 			fprintf(stderr, "\"order\" contradicts \"handle\"\n");

--=-KpunSdDXcdtRJP5Jjd6F--

