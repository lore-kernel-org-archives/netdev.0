From: "David S. Miller" <davem@redhat.com>
Subject: FIX (was Re: Demonstration code on how to trigger tcp6_sock leak)
Date: Mon, 26 Jan 2004 12:30:42 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040126.123042.104046496.davem@redhat.com>
References: <20040124131307.GB2666@bender.home.hensema.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, acme@conectiva.com.br, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: erik@hensema.net
In-Reply-To: <20040124131307.GB2666@bender.home.hensema.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok, I've figured out the bug.  Arnaldo only fixed one of the
two incorrect calls to sk_add_node() which should both be
__sk_add_node().

Erik give this a spin.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1520  -> 1.1521 
#	 net/ipv6/tcp_ipv6.c	1.76    -> 1.77   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/01/26	davem@nuts.ninka.net	1.1521
# [IPV6]: Fix TCP socket leak, do not grab socket reference when adding to main hashes.
# --------------------------------------------
#
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	Mon Jan 26 12:34:20 2004
+++ b/net/ipv6/tcp_ipv6.c	Mon Jan 26 12:34:20 2004
@@ -485,7 +485,7 @@
 
 unique:
 	BUG_TRAP(sk_unhashed(sk));
-	sk_add_node(sk, &head->chain);
+	__sk_add_node(sk, &head->chain);
 	sk->sk_hashent = hash;
 	sock_prot_inc_use(sk->sk_prot);
 	write_unlock_bh(&head->lock);
