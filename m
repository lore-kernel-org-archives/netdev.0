From: Michele Petrazzo - Unipex <michele.petrazzo@unipex.it>
Subject: [patch] [iproute] ip exit, ip and tc line number
Date: Tue, 02 Mar 2010 19:28:41 +0100
Message-ID: <4B8D58D9.7050202@unipex.it>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000505060107060003020400"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.go-wipex.it ([89.202.235.7]:55918 "EHLO smtp.go-wipex.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753294Ab0CBSh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 13:37:27 -0500
Received: from unipex-local-server (unipex.wipex [172.16.20.247])
	by smtp.go-wipex.it (Postfix) with ESMTP id 0141B10B006B
	for <netdev@vger.kernel.org>; Tue,  2 Mar 2010 19:28:43 +0100 (CET)
Received: from [192.168.1.103] (michele [192.168.1.103])
	by unipex-local-server (Postfix) with ESMTP id 1FA1E450683
	for <netdev@vger.kernel.org>; Tue,  2 Mar 2010 19:28:42 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000505060107060003020400
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,
I create a small patch that solve an annoying problem that I found on 
"ip -batch" usage, so the command exits without end the parsing of the 
batch file also if I specify the -force switch.
Also add the shown of the right line number where batch file fail for 
both ip and tc

Michele

--------------000505060107060003020400
Content-Type: text/x-diff;
 name="iproute.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="iproute.diff"

commit 805fac22865d50b561643e58f5c2c001439a6a7d
Author: Michele Petrazzo <michele.petrazzo@unipex.it>
Date:   Tue Mar 2 19:12:50 2010 +0100

    Resolving "ip" exit on batch usage and add to ip and tc commands
    the right line number on the output message then use with batch
    switch
    
    Signed-off-by: Michele Petrazzo <michele.petrazzo@unipex.it>

diff --git a/ip/ip.c b/ip/ip.c
index ace8cc6..b8c4914 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -125,6 +125,9 @@ static int batch(const char *name)
 			if (!force)
 				break;
 		}
+        else {
+            lineno++;
+        }
 	}
 	if (line)
 		free(line);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index e9256d9..8ec6cfd 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1014,7 +1014,7 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 	}
 	if (l && matches(d, l) != 0) {
 		fprintf(stderr, "\"dev\" (%s) must match \"label\" (%s).\n", d, l);
-		exit(1);
+		return -1;
 	}
 
 	if (peer_len == 0 && local_len) {
@@ -1079,7 +1079,7 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 	}
 
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL, NULL, NULL) < 0)
-		exit(2);
+		return -2;
 
 	return 0;
 }
diff --git a/tc/tc.c b/tc/tc.c
index 8e362d2..ce78621 100644
--- a/tc/tc.c
+++ b/tc/tc.c
@@ -250,6 +250,11 @@ static int batch(const char *name)
 			if (!force)
 				break;
 		}
+        else {
+            cmdlineno++;
+        }
+           
+
 	}
 	if (line)
 		free(line);

--------------000505060107060003020400--
