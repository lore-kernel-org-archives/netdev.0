From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2] dont skip action order
Date: Sun, 22 Dec 2013 10:37:44 -0500
Message-ID: <52B70748.8050006@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000803080304020809070208"
To: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:46039 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613Ab3LVPhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 10:37:48 -0500
Received: by mail-ie0-f177.google.com with SMTP id tp5so5065138ieb.22
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 07:37:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000803080304020809070208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


attached.

cheers,
jamal

--------------000803080304020809070208
Content-Type: text/plain; charset=us-ascii;
 name="dont-skip-action-order-index"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="dont-skip-action-order-index"

commit 58d78f9f6447df324cdeb99262442c5e3f1f924b
Author: Jamal Hadi Salim <jhs@mojatatu.com>
Date:   Sun Dec 22 10:34:18 2013 -0500

    dont skip displaying of action chains or lists by TCA_ACT_MAX_PRIO
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/tc/m_action.c b/tc/m_action.c
index 51085ec..77479d6 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -32,7 +32,6 @@ static struct action_util * action_list;
 #ifdef CONFIG_GACT
 int gact_ld = 0 ; //fuckin backward compatibility
 #endif
-int batch_c = 0;
 int tab_flush = 0;
 
 static void act_usage(void)
@@ -304,7 +303,7 @@ tc_print_action(FILE * f, const struct rtattr *arg)
 
 	for (i = 0; i < TCA_ACT_MAX_PRIO; i++) {
 		if (tb[i]) {
-			fprintf(f, "\n\taction order %d: ", i + batch_c);
+			fprintf(f, "\n\taction order %d: ", i);
 			if (0 > tc_print_one_action(f, tb[i])) {
 				fprintf(f, "Error printing action\n");
 			}
@@ -312,7 +311,6 @@ tc_print_action(FILE * f, const struct rtattr *arg)
 
 	}
 
-	batch_c+=TCA_ACT_MAX_PRIO ;
 	return 0;
 }
 

--------------000803080304020809070208--
