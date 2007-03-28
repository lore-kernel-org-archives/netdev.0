From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RESEND] [NET] fib_rules: Flush route cache after rule modifications
Date: Wed, 28 Mar 2007 17:49:03 +0200
Message-ID: <20070328154903.GO521@postel.suug.ch>
References: <20070327133845.GM521@postel.suug.ch> <20070328111921.GA2703@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, muli@il.ibm.com
To: davem@davemloft.net, Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:35009 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932332AbXC1Psm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 11:48:42 -0400
Content-Disposition: inline
In-Reply-To: <20070328111921.GA2703@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jarek Poplawski <jarkao2@o2.pl> 2007-03-28 13:19
> I hope I'm wrong, but isn't this at the cost of admins
> working with long rules' sets, which (probably) take extra
> time now?

That's right, it makes the insert and delete operation more
expensive.

A compromise would be to delay the flushing and wait for
some time (default 2 seconds) whether more rules or routes
are being added before flushing.

[NET] fib_rules: delay route cache flush by ip_rt_min_delay

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: linux/net-2.6.22/net/decnet/dn_rules.c
===================================================================
--- linux.orig/net-2.6.22/net/decnet/dn_rules.c	2007-03-28 17:41:22.000000000 +0200
+++ linux/net-2.6.22/net/decnet/dn_rules.c	2007-03-28 17:41:39.000000000 +0200
@@ -242,7 +242,7 @@ static u32 dn_fib_rule_default_pref(void
 
 static void dn_fib_rule_flush_cache(void)
 {
-	dn_rt_cache_flush(0);
+	dn_rt_cache_flush(-1);
 }
 
 static struct fib_rules_ops dn_fib_rules_ops = {
Index: linux/net-2.6.22/net/ipv4/fib_rules.c
===================================================================
--- linux.orig/net-2.6.22/net/ipv4/fib_rules.c	2007-03-28 17:41:18.000000000 +0200
+++ linux/net-2.6.22/net/ipv4/fib_rules.c	2007-03-28 17:41:30.000000000 +0200
@@ -300,7 +300,7 @@ static size_t fib4_rule_nlmsg_payload(st
 
 static void fib4_rule_flush_cache(void)
 {
-	rt_cache_flush(0);
+	rt_cache_flush(-1);
 }
 
 static struct fib_rules_ops fib4_rules_ops = {
