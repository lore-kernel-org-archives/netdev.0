From: =?ISO-8859-1?Q?Philipp_Sch=F6nberger?=
	<ph.schoenberger@googlemail.com>
Subject: [iproute2 PATCH] tc: handle is not used without containing ':'
Date: Thu, 13 Jun 2013 19:20:52 +0200
Message-ID: <CAABrY5pGnVQPctPUSJAiM0tp3o2OTxjG5y8yt3bY59r=x2Gksg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f50.google.com ([209.85.128.50]:60627 "EHLO
	mail-qe0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756333Ab3FMRUx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 13:20:53 -0400
Received: by mail-qe0-f50.google.com with SMTP id f6so6728482qej.9
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 10:20:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle is not used if it is not containing a ':' . This is
reproducible with these commands.

/sbin/tc qdisc add dev lo parent 0xffffffff handle 0x10000 pfifo limit =
10

/sbin/tc qdisc show dev lo
qdisc pfifo 8001: root refcnt 2 limit 10p

Signed-off-by: Philipp Sch=F6nberger <ph.schoenberger@googlemail.com>
--- iproute2-2.6.33/tc/tc_util.c    2010-02-25 04:56:50.000000000 +0100
+++ /home/pschoen/tc_util.c    2013-06-13 18:31:00.347135625 +0200
@@ -50,9 +50,14 @@
     maj =3D strtoul(str, &p, 16);
     if (p =3D=3D str)
         return -1;
-    maj <<=3D 16;
-    if (*p !=3D ':' && *p!=3D0)
-        return -1;
+    if (*p !=3D ':')
+    {
+        if(*p!=3D0)
+            return -1;
+        else if (TC_H_MIN(maj) !=3D 0)
+            return -1;
+    }else
+        maj <<=3D 16;
 ok:
     *h =3D maj;
     return 0;
