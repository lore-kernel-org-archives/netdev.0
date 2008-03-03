From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: [PATCH v2] ipv6: fix icmpv6_cleanup/icmpv6_init section mismatch
Date: Mon, 3 Mar 2008 17:54:51 +0300
Message-ID: <20080303145451.GC6026@localhost.sw.ru>
References: <20080303125217.GA6026@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:5376 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757386AbYCCOzA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 09:55:00 -0500
Content-Disposition: inline
In-Reply-To: <20080303125217.GA6026@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 03, 2008 at 03:52:17PM +0300, Alexey Dobriyan wrote:
> icmpv6_cleanup() is called from inet6_init() which is __init, so the
> former can't be __exit.

Doh! Ignore this one. Below is correct.
--------

[PATCH] ipv6: fix inet6_init/icmpv6_cleanup sections mismatch

Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
---

 net/ipv6/icmp.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -844,7 +844,7 @@ static void __net_exit icmpv6_sk_exit(struct net *net)
 	kfree(net->ipv6.icmp_sk);
 }
 
-static struct pernet_operations __net_initdata icmpv6_sk_ops = {
+static struct pernet_operations icmpv6_sk_ops = {
        .init = icmpv6_sk_init,
        .exit = icmpv6_sk_exit,
 };
@@ -868,7 +868,7 @@ fail:
 	return err;
 }
 
-void __exit icmpv6_cleanup(void)
+void icmpv6_cleanup(void)
 {
 	unregister_pernet_subsys(&icmpv6_sk_ops);
 	inet6_del_protocol(&icmpv6_protocol, IPPROTO_ICMPV6);

