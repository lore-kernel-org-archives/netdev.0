From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: ipv6: fix icmpv6_cleanup/icmpv6_init section mismatch
Date: Mon, 3 Mar 2008 15:52:17 +0300
Message-ID: <20080303125217.GA6026@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:25029 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756330AbYCCMw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 07:52:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

icmpv6_cleanup() is called from inet6_init() which is __init, so the
former can't be __exit.

Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
---

 net/ipv6/icmp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -868,7 +868,7 @@ fail:
 	return err;
 }
 
-void __exit icmpv6_cleanup(void)
+void icmpv6_cleanup(void)
 {
 	unregister_pernet_subsys(&icmpv6_sk_ops);
 	inet6_del_protocol(&icmpv6_protocol, IPPROTO_ICMPV6);

