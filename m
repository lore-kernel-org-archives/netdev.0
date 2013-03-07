From: jb <jb.1234abcd@gmail.com>
Subject: [PATCH] iputils: fix memory leaks
Date: Thu, 7 Mar 2013 09:52:22 +0000 (UTC)
Message-ID: <loom.20130307T103516-549@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:33661 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752897Ab3CGJyu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 04:54:50 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UDXXV-0005HA-Al
	for netdev@vger.kernel.org; Thu, 07 Mar 2013 10:55:05 +0100
Received: from 79-139-19-75.prenet.pl ([79.139.19.75])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 10:55:05 +0100
Received: from jb.1234abcd by 79-139-19-75.prenet.pl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 10:55:05 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


    Fix memory leaks
    
    Signed-off-by: JB <jb.1234abcd@gmail.com>
---
 ping.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/ping.c b/ping.c
index c0366cd..04f5596 100644
--- a/ping.c
+++ b/ping.c
@@ -282,10 +282,15 @@ main(int argc, char **argv)
                        hp = gethostbyname(idn);
                        if (!hp) {
                                fprintf(stderr, "ping: unknown host %s\n", target);
+#ifdef USE_IDN
+                               free(idn);
+                               idn = NULL;
+#endif
                                exit(2);
                        }
 #ifdef USE_IDN
                        free(idn);
+                       idn = NULL;
 #endif
                        memcpy(&whereto.sin_addr, hp->h_addr, 4);
 #ifdef USE_IDN
@@ -301,6 +306,10 @@ main(int argc, char **argv)
                        hnamebuf[sizeof(hnamebuf) - 1] = 0;
 #endif
                        hostname = hnamebuf;
+#ifdef USE_IDN
+                       free(hnamebuf);
+                       hnamebuf = NULL;
+#endif
                }
                if (argc > 1)
                        route[nroute++] = whereto.sin_addr.s_addr;
