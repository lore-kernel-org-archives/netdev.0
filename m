From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: few more fixes for iproute2/m_ipt
Date: Wed, 6 Aug 2008 15:50:41 +0300
Message-ID: <200808061550.42003.denys@visp.net.lb>
References: <200808060042.53503.denys@visp.net.lb> <200808061426.36605.denys@visp.net.lb> <1218026760.4755.60.camel@localhost>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_i4ZmIHEXfxaFFaX"
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:36356 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752464AbYHFMvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 08:51:35 -0400
In-Reply-To: <1218026760.4755.60.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_i4ZmIHEXfxaFFaX
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 06 August 2008, jamal wrote:
> cheers,
> jamal
> PS:- dont wanna sound anal - and you dont have to do this if you dont
> have time; but if you put the resetting of optind and the flags in a
> separate patch from the freeing, that would be even better.
Yes, i did already
Attaching patches



--Boundary-00=_i4ZmIHEXfxaFFaX
Content-Type: text/x-diff;
  charset="koi8-r";
  name="01-iproute-memleak_fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="01-iproute-memleak_fix.patch"

diff -Naur iproute2-original/tc/m_ipt.c iproute2-patched/tc/m_ipt.c
--- iproute2-original/tc/m_ipt.c	2008-08-05 19:15:56.000000000 +0000
+++ iproute2-patched/tc/m_ipt.c	2008-08-06 11:13:47.000000000 +0000
@@ -277,6 +277,8 @@
 		if (!handle) {
 			fputs(dlerror(), stderr);
 			printf("\n");
+			free(l_name);
+			free(new_name);
 			return NULL;
 		}
 	}
@@ -292,12 +294,16 @@
 					fputs(error, stderr);
 					fprintf(stderr, "\n");
 					dlclose(handle);
+					free(l_name);
+					free(new_name);
 					return NULL;
 				}
 			}
 		}
 	}
 
+	free(l_name);
+	free(new_name);
 	return m;
 }
 
@@ -514,6 +520,13 @@
 
 	optind = 1;
 	free_opts(opts);
+	/* Clear flags if target will be used again */
+        m->tflags=0;
+        m->used=0;
+	/* Free allocated memory */
+        if (m->t)
+            free(m->t);
+
 
 	return 0;
 

--Boundary-00=_i4ZmIHEXfxaFFaX
Content-Type: text/x-diff;
  charset="koi8-r";
  name="02-iproute-optind_zero.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="02-iproute-optind_zero.patch"

diff -Naur iproute2-patched/tc/m_ipt.c iproute2-patched2/tc/m_ipt.c
--- iproute2-patched/tc/m_ipt.c	2008-08-06 11:13:47.000000000 +0000
+++ iproute2-patched2/tc/m_ipt.c	2008-08-06 11:14:58.000000000 +0000
@@ -518,7 +518,7 @@
 	*argc_p = rargc - iargc;
 	*argv_p = argv;
 
-	optind = 1;
+	optind = 0;
 	free_opts(opts);
 	/* Clear flags if target will be used again */
         m->tflags=0;

--Boundary-00=_i4ZmIHEXfxaFFaX--
