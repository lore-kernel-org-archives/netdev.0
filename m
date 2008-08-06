From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: few more fixes for iproute2/m_ipt
Date: Wed, 6 Aug 2008 15:59:07 +0300
Message-ID: <200808061559.07923.denys@visp.net.lb>
References: <200808060042.53503.denys@visp.net.lb> <200808061550.42003.denys@visp.net.lb> <1218027312.4755.63.camel@localhost>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_bAamIUj0mgUz8WA"
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:32987 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbYHFM7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 08:59:55 -0400
In-Reply-To: <1218027312.4755.63.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_bAamIUj0mgUz8WA
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 06 August 2008, jamal wrote:
> On Wed, 2008-06-08 at 15:50 +0300, Denys Fedoryshchenko wrote:
> > +       /* Clear flags if target will be used again */
> > +        m->tflags=0;
> > +        m->used=0;
> > +       /* Free allocated memory */
> > +        if (m->t)
> > +            free(m->t);
> > +
>
> I meant moving the above to 02-iproute-optind_zero.patch
>
> No big deal if you dont have time.
>
> cheers,
> jamal

This one?


--Boundary-00=_bAamIUj0mgUz8WA
Content-Type: text/x-diff;
  charset="koi8-r";
  name="01-iproute-memleak_optind-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="01-iproute-memleak_optind-fix.patch"

diff -Naur iproute2-original/tc/m_ipt.c iproute2-patched/tc/m_ipt.c
--- iproute2-original/tc/m_ipt.c	2008-08-05 19:15:56.000000000 +0000
+++ iproute2-patched/tc/m_ipt.c	2008-08-05 21:39:49.000000000 +0000
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
 
@@ -512,8 +518,15 @@
 	*argc_p = rargc - iargc;
 	*argv_p = argv;
 
-	optind = 1;
+	optind = 0;
 	free_opts(opts);
+	/* Clear flags if target will be used again */
+        m->tflags=0;
+        m->used=0;
+	/* Free allocated memory */
+        if (m->t)
+            free(m->t);
+
 
 	return 0;
 

--Boundary-00=_bAamIUj0mgUz8WA--
