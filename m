From: jamal <hadi@cyberus.ca>
Subject: [Fwd: [IPROUTE2]: Explicit BNF definition for actions]
Date: Sat, 05 Aug 2006 12:42:35 -0400
Message-ID: <1154796155.5081.6.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-grM1z/WjCAY2T9UJsZQW"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:57762 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932418AbWHEQmi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 12:42:38 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G9PEW-0001Ca-Tc
	for netdev@vger.kernel.org; Sat, 05 Aug 2006 12:42:40 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-grM1z/WjCAY2T9UJsZQW
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Stephen,

This is the one after the last one you responded to. Your git tree is
not uptodate so i cant tell if you are missing it or not ;->

I dont think i will be making more updates for this release - more to
come later.

cheers,
jamal

-------- Forwarded Message --------
From: jamal <hadi@cyberus.ca>
Reply-To: hadi@cyberus.ca
To: Stephen Hemminger <shemminger@osdl.org>
Subject: [IPROUTE2]: Explicit BNF definition for actions
Date: Sun, 30 Jul 2006 20:04:41 -0400

Stephen,
Patch attached. I wanted to send more but my body decided to get sick. 
So go ahead and make a release with just this - In the future i should
be able to send more. If you sync all the patches with your tree, when i
git i should be able to tell if you are missing any..

cheers,
jamal

--=-grM1z/WjCAY2T9UJsZQW
Content-Disposition: attachment; filename=act_u11
Content-Type: text/plain; name=act_u11; charset=UTF-8
Content-Transfer-Encoding: 7bit

Add explicit help text for actions

---
commit 87d5ee5fddd9476bd720ea339f6ddb237d6eb99c
tree 1888b85dbb7a724df0a215c7f1a07b857a3cd00b
parent e2e0fac73a39bc6878f93cd7698f4c823ef85546
author Jamal Hadi Salim <hadi@cyberus.ca> Sun, 30 Jul 2006 20:00:37 -0400
committer Jamal Hadi Salim <hadi@jzny2.(none)> Sun, 30 Jul 2006 20:00:37 -0400

 tc/m_action.c |   25 +++++++++++++++++++++++--
 tc/m_gact.c   |    4 +++-
 2 files changed, 26 insertions(+), 3 deletions(-)

diff --git a/tc/m_action.c b/tc/m_action.c
index c612069..3808a86 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -37,7 +37,28 @@ int tab_flush = 0;
 
 void act_usage(void)
 {
-	fprintf (stderr, "action usage improper\n");
+	/*XXX: In the near future add a action->print_help to improve
+	 * usability
+	 * This would mean new tc will not be backward compatible
+	 * with any action .so from the old days. But if someone really
+	 * does that, they would know how to fix this ..
+	 *
+	*/
+	fprintf (stderr, "usage: tc actions <ACTSPECOP>*\n");
+	fprintf(stderr,
+		"Where: \tACTSPECOP := ACR | GD | FL\n"
+			"\tACR := add | change | replace <ACTSPEC>* \n"
+			"\tGD := get | delete | <ACTISPEC>*\n"
+			"\tFL := ls | list | flush | <ACTNAMESPEC>\n"
+			"\tACTNAMESPEC :=  action <ACTNAME>\n"
+			"\tACTISPEC := <ACTNAMESPEC> <INDEXSPEC>\n"
+			"\tACTSPEC := action <ACTDETAIL> [INDEXSPEC]\n"
+			"\tINDEXSPEC := index <32 bit indexvalue>\n"
+			"\tACTDETAIL := <ACTNAME> <ACTPARAMS>\n"
+			"\t\tExample ACTNAME is gact, mirred etc\n"
+			"\t\tEach action has its own parameters (ACTPARAMS)\n"
+			"\n");
+
 	exit(-1);
 }
 
@@ -599,7 +620,7 @@ int do_action(int argc, char **argv)
 		}
 
 		if (ret < 0) {
-			fprintf(stderr, "Command \"%s\" is unknown, try \"tc action help\".\n", *argv);
+			fprintf(stderr, "Command \"%s\" is unknown, try \"tc actions help\".\n", *argv);
 			return -1;
 		}
 	}
diff --git a/tc/m_gact.c b/tc/m_gact.c
index 4e3f3c7..cfbaf87 100644
--- a/tc/m_gact.c
+++ b/tc/m_gact.c
@@ -56,7 +56,7 @@ #else
 	fprintf(stderr,
 		"Where: \tACTION := reclassify | drop | continue | pass \n"
 		"\tINDEX := index value used\n"
-			"\n");
+		"\n");
 #endif
 }
 
@@ -179,6 +179,8 @@ #endif
 			argc--;
 			argv++;
 			ok++;
+		} else if (matches(*argv, "help") == 0) {
+				usage();
 		}
 	}
 

--=-grM1z/WjCAY2T9UJsZQW--

