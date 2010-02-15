From: jamal <hadi@cyberus.ca>
Subject: [PATCH iproute2]: skbedit: use get_u32 for parsing mark
Date: Mon, 15 Feb 2010 06:51:01 -0500
Message-ID: <1266234661.6776.82.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-YPdui9XmwFIg1s8lULfR"
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f200.google.com ([209.85.221.200]:47463 "EHLO
	mail-qy0-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755294Ab0BOLvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 06:51:05 -0500
Received: by qyk38 with SMTP id 38so149004qyk.1
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2010 03:51:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YPdui9XmwFIg1s8lULfR
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


parsing a mark as a classid allows for acceptance of strange
informal input.

cheers,
jamal


--=-YPdui9XmwFIg1s8lULfR
Content-Disposition: attachment; filename="skbedu32"
Content-Type: text/plain; name="skbedu32"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit aad0da6507ff8a95a63ed8e529c05f52be5b0e75
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Mon Feb 15 06:45:29 2010 -0500

    skbedit: use get_u32 for parsing mark
    
    get_u32 is the more appropriate parser for a mark.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
index 5d1a96a..990b9c7 100644
--- a/tc/m_skbedit.c
+++ b/tc/m_skbedit.c
@@ -86,7 +86,7 @@ parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 		} else if (matches(*argv, "mark") == 0) {
 			flags |= SKBEDIT_F_MARK;
 			NEXT_ARG();
-			if (get_tc_classid(&mark, *argv)) {
+			if (get_u32(&mark, *argv, 0)) {
 				fprintf(stderr, "Illegal mark\n");
 				return -1;
 			}

--=-YPdui9XmwFIg1s8lULfR--

