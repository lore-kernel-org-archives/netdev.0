From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 1/1] policer - retire old syntax
Date: Sat, 21 Dec 2013 17:16:53 -0500
Message-ID: <52B61355.6060602@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010808060008050506030300"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:53953 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab3LUWQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 17:16:56 -0500
Received: by mail-ig0-f174.google.com with SMTP id hk11so18236759igb.1
        for <netdev@vger.kernel.org>; Sat, 21 Dec 2013 14:16:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010808060008050506030300
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


attached.

cheers,
jamal

--------------010808060008050506030300
Content-Type: text/plain; charset=us-ascii;
 name="kill-old-police-syntax"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="kill-old-police-syntax"

commit b82057d9ec851a8aba8a295b959190ef5098f330
Author: Jamal Hadi Salim <jhs@mojatatu.com>
Date:   Sat Dec 21 17:00:11 2013 -0500

    After a decade of trying to deprecate the old policer syntax,
    I believe it is time to kill it. The kernel build option for old
    policer is gone for at least 5 years now (although backward
    compatibility is still there). Being backward compatible meant
    hijacking the keyword "action" and was obstructing policies like:
    
    tc filter add dev eth0 parent ffff: protocol ip pref 10 \
    u32 match ip protocol 1 0xff flowid 1:10 \
    action skbedit mark 1 \
    action police rate 10kbit burst 10k pipe \
    action skbedit mark 2 \
    action police rate 20kbit burst 20k pipe \
    action action mirred egress mirror dev dummy0
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/tc/m_police.c b/tc/m_police.c
index 300287e..df295e0 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -38,7 +38,6 @@ static void usage(void)
 	fprintf(stderr, "                [ peakrate BPS ] [ avrate BPS ] [ overhead BYTES ]\n");
 	fprintf(stderr, "                [ linklayer TYPE ] [ ACTIONTERM ]\n");
 
-	fprintf(stderr, "Old Syntax ACTIONTERM := action <EXCEEDACT>[/NOTEXCEEDACT] \n");
 	fprintf(stderr, "New Syntax ACTIONTERM := conform-exceed <EXCEEDACT>[/NOTEXCEEDACT] \n");
 	fprintf(stderr, "Where: *EXCEEDACT := pipe | ok | reclassify | drop | continue \n");
 	fprintf(stderr, "Where:  pipe is only valid for new syntax \n");
@@ -150,6 +149,7 @@ int act_parse_police(struct action_util *a,int *argc_p, char ***argv_p, int tca_
 
 	while (argc > 0) {
 
+		fprintf(stderr,"police argc %d argv %s\n", argc, *argv);
 		if (matches(*argv, "index") == 0) {
 			NEXT_ARG();
 			if (get_u32(&p.index, *argv, 10)) {
@@ -230,8 +230,7 @@ int act_parse_police(struct action_util *a,int *argc_p, char ***argv_p, int tca_
 			p.action = TC_POLICE_OK;
 		} else if (matches(*argv, "pipe") == 0) {
 			p.action = TC_POLICE_PIPE;
-		} else if (strcmp(*argv, "action") == 0 ||
-			   strcmp(*argv, "conform-exceed") == 0) {
+		} else if (strcmp(*argv, "conform-exceed") == 0) {
 			NEXT_ARG();
 			if (get_police_result(&p.action, &presult, *argv)) {
 				fprintf(stderr, "Illegal \"action\"\n");

--------------010808060008050506030300--
