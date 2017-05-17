From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH net-next] net: make struct dst_entry::dev first member
Date: Wed, 17 May 2017 19:31:39 +0300
Message-ID: <20170517163138.GA5269@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36096 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751900AbdEQQbo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 12:31:44 -0400
Received: by mail-wm0-f65.google.com with SMTP id k15so3449341wmh.3
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 09:31:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct dst_entry::dev is used most often. Move it so it can be
accessed without imm8 offset on x86_64.

	add/remove: 0/0 grow/shrink: 9/239 up/down: 52/-413 (-361)
	function                                     old     new   delta
	dst_rcu_free                                 126     138     +12
	fnhe_flush_routes                            211     219      +8
	rt_set_nexthop                               747     754      +7
	rt_cache_route                                85      91      +6
	rt6_release                                  209     215      +6
	dst_release                                  107     111      +4
	dst_destroy_rcu                               29      33      +4
	dn_dst_check_expire                          329     333      +4
	dn_insert_route                              484     485      +1
	xfrm_resolve_and_create_bundle              2991    2990      -1
					...
	ip_route_me_harder                          1163    1157      -6
	__ip_append_data.isra                       2730    2724      -6
	ip6_forward                                 3052    3045      -7
	callforward_do_filter                        659     651      -8
	dst_gc_task                                  571     549     -22

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/dst.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -31,9 +31,9 @@
 struct sk_buff;
 
 struct dst_entry {
+	struct net_device       *dev;
 	struct rcu_head		rcu_head;
 	struct dst_entry	*child;
-	struct net_device       *dev;
 	struct  dst_ops	        *ops;
 	unsigned long		_metrics;
 	unsigned long           expires;
