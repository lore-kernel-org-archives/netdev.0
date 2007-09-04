From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: [patch] sunrpc: fix printk argument in svc_tcp_accept
Date: Tue, 4 Sep 2007 02:05:26 +0200
Message-ID: <200709040205.26276.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:59165 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751123AbXIDAZH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2007 20:25:07 -0400
Received: from mailhub.studentenwerk.mhn.de (mail.studentenwerk.mhn.de [10.148.7.34])
	by email.studentenwerk.mhn.de (Postfix) with ESMTP id CB37358002
	for <netdev@vger.kernel.org>; Tue,  4 Sep 2007 02:05:26 +0200 (CEST)
Received: from mist.as.studentenwerk.mhn.de (mist.as.studentenwerk.mhn.de [10.148.0.198])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mailhub.studentenwerk.mhn.de (Postfix) with ESMTP id BB4469FB54
	for <netdev@vger.kernel.org>; Tue,  4 Sep 2007 02:05:26 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

in 2.6.22.6, net/sunrpc/svcsock.c

random characters are printed by svc_tcp_accept:

	lockd: last TCP connect from <some random chars>

because buf is used unitialized:

printk(KERN_NOTICE
	"%s: last TCP connect from %s\n",
	serv->sv_name, buf);


Probably it should be

printk(KERN_NOTICE
	"%s: last TCP connect from %s\n",
	serv->sv_name, __svc_print_addr(sin, buf, sizeof(buf)));



Signed-off-by: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>

################
--- linux-2.6.22.6/net/sunrpc/svcsock.c	2007-08-27 18:10:14.000000000 +=
0200
+++ linux-2.6.22.6w/net/sunrpc/svcsock.c	2007-09-03 18:27:30.000000000 =
+0200
@@ -1090,7 +1090,7 @@
 						   serv->sv_name);
 				printk(KERN_NOTICE
 				       "%s: last TCP connect from %s\n",
-				       serv->sv_name, buf);
+				       serv->sv_name, __svc_print_addr(sin, buf, sizeof(buf)));
 			}
 			/*
 			 * Always select the oldest socket. It's not fair,

################

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
