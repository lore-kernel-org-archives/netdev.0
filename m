From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6_V6ONLY Support, v2 (is Re: [PATCH] IPv6: Allow
 Both IPv6 and IPv4 Sockets on the Same Port)
Date: Wed, 23 Oct 2002 16:58:32 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021023.165832.11432472.yoshfuji@linux-ipv6.org>
References: <200210031552.TAA29921@sex.inr.ac.ru>
	<20021023.162439.114324450.yoshfuji@linux-ipv6.org>
	<20021023.002303.67097780.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20021023.002303.67097780.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20021023.002303.67097780.davem@redhat.com> (at Wed, 23 Oct 2002 00:23:03 -0700 (PDT)), "David S. Miller" <davem@redhat.com> says:

> So, because you simplified some if clauses in Alexey's patch, USAGI is
> the only entity who deserves credit for the work in the comments?
> 
> That's dishonest.  Please fix this.

Hmm, we simplified our patch based on original linux kernel.
In fact, I use ipv6_only_sock() from his patch.
Sorry about that, apply this agaist that patch:

Index: net/ipv4/tcp_ipv4.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv4/tcp_ipv4.c,v
retrieving revision 1.1.1.2.16.2
diff -u -r1.1.1.2.16.2 tcp_ipv4.c
--- net/ipv4/tcp_ipv4.c	22 Oct 2002 19:40:48 -0000	1.1.1.2.16.2
+++ net/ipv4/tcp_ipv4.c	23 Oct 2002 07:46:23 -0000
@@ -45,8 +45,8 @@
  *	Vitaly E. Lavrov	:	Transparent proxy revived after year coma.
  *	Andi Kleen		:	Fix new listen.
  *	Andi Kleen		:	Fix accept error reporting.
- *	YOSHIFUJI Hideaki @USAGI:	Support IPV6_V6ONLY socket option, which
- *					allow both IPv4 and IPv6 sockets to bind
+ *	YOSHIFUJI Hideaki @USAGI and:	Support IPV6_V6ONLY socket option, which
+ *	and Alexey Kuznetsov		allow both IPv4 and IPv6 sockets to bind
  *					a single port at the same time.
  */
 
Index: net/ipv4/udp.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv4/udp.c,v
retrieving revision 1.1.1.1.40.1
diff -u -r1.1.1.1.40.1 udp.c
--- net/ipv4/udp.c	22 Oct 2002 19:19:48 -0000	1.1.1.1.40.1
+++ net/ipv4/udp.c	23 Oct 2002 07:46:23 -0000
@@ -61,8 +61,8 @@
  *					return ENOTCONN for unconnected sockets (POSIX)
  *		Janos Farkas	:	don't deliver multi/broadcasts to a different
  *					bound-to-device socket
- *	YOSHIFUJI Hideaki @USAGI:	Support IPV6_V6ONLY socket option, which
- *					allow both IPv4 and IPv6 sockets to bind
+ *	YOSHIFUJI Hideaki @USAGI and:	Support IPV6_V6ONLY socket option, which
+ *	and Alexey Kuznetsov:		allow both IPv4 and IPv6 sockets to bind
  *					a single port at the same time.
  *
  *
Index: net/ipv6/tcp_ipv6.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv6/tcp_ipv6.c,v
retrieving revision 1.1.1.2.16.1
diff -u -r1.1.1.2.16.1 tcp_ipv6.c
--- net/ipv6/tcp_ipv6.c	22 Oct 2002 19:19:48 -0000	1.1.1.2.16.1
+++ net/ipv6/tcp_ipv6.c	23 Oct 2002 07:46:23 -0000
@@ -14,8 +14,8 @@
  *
  *	Fixes:
  *	Hideaki YOSHIFUJI	:	sin6_scope_id support
- *	YOSHIFUJI Hideaki @USAGI:	Support IPV6_V6ONLY socket option, which
- *					allow both IPv4 and IPv6 sockets to bind
+ *	YOSHIFUJI Hideaki @USAGI and:	Support IPV6_V6ONLY socket option, which
+ *	Alexey Kuznetsov		allow both IPv4 and IPv6 sockets to bind
  *					a single port at the same time.
  *
  *	This program is free software; you can redistribute it and/or
Index: net/ipv6/udp.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv6/udp.c,v
retrieving revision 1.1.1.2.16.1
diff -u -r1.1.1.2.16.1 udp.c
--- net/ipv6/udp.c	22 Oct 2002 19:19:48 -0000	1.1.1.2.16.1
+++ net/ipv6/udp.c	23 Oct 2002 07:46:23 -0000
@@ -11,8 +11,8 @@
  *
  *	Fixes:
  *	Hideaki YOSHIFUJI	:	sin6_scope_id support
- *	YOSHIFUJI Hideaki @USAGI:	Support IPV6_V6ONLY socket option, which
- *					allow both IPv4 and IPv6 sockets to bind
+ *	YOSHIFUJI Hideaki @USAGI and:	Support IPV6_V6ONLY socket option, which
+ *	Alexey Kuznetsov		allow both IPv4 and IPv6 sockets to bind
  *					a single port at the same time.
  *
  *	This program is free software; you can redistribute it and/or

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
