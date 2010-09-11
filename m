From: Michael Kerrisk <mtk.manpages@gmail.com>
Subject: [PATCH] enable getsockopt() for IP_NODEFRAG
Date: Sat, 11 Sep 2010 08:26:56 +0200
Message-ID: <4C8B2130.7030605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jengelh@medozas.de, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-man@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Jiri

While integrating your man-pages patch for IP_NODEFRAG, I noticed 
that this option is settable by setsockopt(), but not gettable by 
getsockopt(). I suppose this is not intended. The (untested, 
trivial) patch below adds getsockopt() support.

The patch is against 2.6.36-rc3.

Cheers,

Michael

PS I've just configured Thunderbird on this machine, hopefully the 
patch is not mangled. Please let me know if there are problems.

Signed-off-by: Michael kerrisk <mtk.manpages@gmail.com>

--- net/ipv4/ip_sockglue.c.orig	2010-09-11 07:25:58.000000000 +0200
+++ net/ipv4/ip_sockglue.c	2010-09-11 07:43:43.000000000 +0200
@@ -1129,6 +1129,9 @@ static int do_ip_getsockopt(struct sock
 	case IP_HDRINCL:
 		val = inet->hdrincl;
 		break;
+	case IP_NODEFRAG:
+		val = inet->nodefrag;
+		break;
 	case IP_MTU_DISCOVER:
 		val = inet->pmtudisc;
 		break;
-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Watch my Linux system programming book progress towards publication!
http://blog.man7.org/
