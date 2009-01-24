From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: why usr/include/linux/if_frad.h is required
Date: Sat, 24 Jan 2009 16:32:55 +0100
Message-ID: <m3ljt0pvmg.fsf@intrepid.localdomain>
References: <20090121053310.GA26395@uranus.ravnborg.org>
	<20090120.221504.264090722.davem@davemloft.net>
	<20090121173838.3390e5c9@s6510>
	<20090121.153712.84781438.davem@davemloft.net>
	<1232803533.17900.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	sam@ravnborg.org, jaswinderlinux@gmail.com, arnd@arndb.de,
	mingo@elte.hu, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jaswinder Singh Rajput <jaswinder@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:45287 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750859AbZAXPc7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2009 10:32:59 -0500
In-Reply-To: <1232803533.17900.4.camel@localhost.localdomain> (Jaswinder Singh Rajput's message of "Sat\, 24 Jan 2009 18\:55\:33 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jaswinder Singh Rajput <jaswinder@kernel.org> writes:

> After killing CONFIG_DLCI and CONFIG_DLCI_MODULE, it is also killing =
the
> kernel:
>
>   CC      net/socket.o
> In file included from net/socket.c:75:
> include/linux/if_frad.h:170: error: =E2=80=98CONFIG_DLCI_MAX=E2=80=99=
 undeclared here (not in a function)

Perhaps this would do (untested).
Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

diff --git a/include/linux/if_frad.h b/include/linux/if_frad.h
index 5c34240..60e16a5 100644
--- a/include/linux/if_frad.h
+++ b/include/linux/if_frad.h
@@ -26,8 +26,6 @@
=20
 #include <linux/if.h>
=20
-#if defined(CONFIG_DLCI) || defined(CONFIG_DLCI_MODULE)
-
 /* Structures and constants associated with the DLCI device driver */
=20
 struct dlci_add
@@ -127,6 +125,8 @@ struct frad_conf
=20
 #ifdef __KERNEL__
=20
+#if defined(CONFIG_DLCI) || defined(CONFIG_DLCI_MODULE)
+
 /* these are the fields of an RFC 1490 header */
 struct frhdr
 {
@@ -190,12 +190,10 @@ struct frad_local
    int               buffer;		/* current buffer for S508 firmware */
 };
=20
-#endif /* __KERNEL__ */
-
 #endif /* CONFIG_DLCI || CONFIG_DLCI_MODULE */
=20
-#ifdef __KERNEL__
 extern void dlci_ioctl_set(int (*hook)(unsigned int, void __user *));
-#endif
+
+#endif /* __KERNEL__ */
=20
 #endif
