From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] ipv4: release dev refcnt early when destroying
 inetdev
Date: Fri, 10 Sep 2010 17:16:14 +0200
Message-ID: <1284131774.24675.46.camel@edumazet-laptop>
References: <4C8A3430.2070105@6wind.com>
	 <1284128679.24675.38.camel@edumazet-laptop>  <4C8A474C.3040502@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54699 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab0IJPQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 11:16:19 -0400
Received: by fxm16 with SMTP id 16so1786429fxm.19
        for <netdev@vger.kernel.org>; Fri, 10 Sep 2010 08:16:18 -0700 (PDT)
In-Reply-To: <4C8A474C.3040502@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 septembre 2010 =C3=A0 16:57 +0200, Nicolas Dichtel a =C3=
=A9crit :

> Is this not true in IPv6? What is the difference?

It might be a bug on ipv6, who knows ?

Releasing a reference count, but not setting idev->dev to NULL is=20
a sign something is wrong...


diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5bc893e..26e39bc 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -330,6 +330,7 @@ void in6_dev_finish_destroy(struct inet6_dev *idev)
 	printk(KERN_DEBUG "in6_dev_finish_destroy: %s\n", dev ? dev->name : "=
NIL");
 #endif
 	dev_put(dev);
+	idev->dev =3D NULL;
 	if (!idev->dead) {
 		pr_warning("Freeing alive inet6 device %p\n", idev);
 		return;


