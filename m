From: Patrick McHardy <kaber@trash.net>
Subject: Re: net/ipv4/inetpeer.c stack warnings
Date: Thu, 19 Jul 2007 14:48:59 +0200
Message-ID: <469F5DBB.3080106@trash.net>
References: <469F5941.7090900@googlemail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080804060201080304000500"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Gabriel C <nix.or.die@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33683 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933960AbXGSMwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 08:52:24 -0400
In-Reply-To: <469F5941.7090900@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080804060201080304000500
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Gabriel C wrote:
> Hello ,
>
> I noticed on current git this warning in net/ipv4/inetpeer.c

Yeah, I have no idea why the gcc people thought that this was
something worth warning about. Especially since explicitly
checking for != NULL silences the warning again.



--------------080804060201080304000500
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPV4]: Fix inetpeer gcc-4.2 warnings

  CC      net/ipv4/inetpeer.o
net/ipv4/inetpeer.c: In function 'unlink_from_pool':
net/ipv4/inetpeer.c:297: warning: the address of 'stack' will always evaluate as 'true'
net/ipv4/inetpeer.c:297: warning: the address of 'stack' will always evaluate as 'true'
net/ipv4/inetpeer.c: In function 'inet_getpeer':
net/ipv4/inetpeer.c:409: warning: the address of 'stack' will always evaluate as 'true'
net/ipv4/inetpeer.c:409: warning: the address of 'stack' will always evaluate as 'true'

"Fix" by checking for != NULL.

Signed-off-by: Patrick McHardy <kaber@trash.net>
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 2f44e61..f725f9f 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -158,7 +158,7 @@ static void unlink_from_unused(struct inet_peer *p)
 #define lookup(_daddr,_stack) 					\
 ({								\
 	struct inet_peer *u, **v;				\
-	if (_stack) {						\
+	if (_stack != NULL) {					\
 		stackptr = _stack;				\
 		*stackptr++ = &peer_root;			\
 	}							\
@@ -169,7 +169,7 @@ static void unlink_from_unused(struct inet_peer *p)
 			v = &u->avl_left;			\
 		else						\
 			v = &u->avl_right;			\
-		if (_stack)					\
+		if (_stack != NULL)				\
 			*stackptr++ = v;			\
 		u = *v;						\
 	}							\

--------------080804060201080304000500--
