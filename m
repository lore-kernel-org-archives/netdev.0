From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH] ipv6: fix signedness of tmp_prefered_lft underflow check
Date: Tue, 18 Oct 2016 17:01:54 +0200
Message-ID: <20161018150154.4tpivtvxygp7kjpd@dwarf.suse.cz>
References: <alpine.DEB.2.20.1610151945380.9280@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kbuild-all@01.org
To: Julia Lawall <julia.lawall@lip6.fr>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54638 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932186AbcJRPCC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 11:02:02 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1610151945380.9280@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 76506a986dc31394fd1f2741db037d29c7e57843 (IPv6: fix
DESYNC_FACTOR) introduced a buggy check for underflow of
tmp_prefered_lft. tmp_prefered_lft is unsigned, so the condition
is always false.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>
Reported-by: Julia Lawall <julia.lawall@lip6.fr>
Fixes: 76506a986dc3 ("IPv6: fix DESYNC_FACTOR")

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cc7c26d..7a043a4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1248,7 +1248,7 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i
 	tmp_prefered_lft = idev->cnf.temp_prefered_lft + age -
 			    idev->desync_factor;
 	/* guard against underflow in case of concurrent updates to cnf */
-	if (unlikely(tmp_prefered_lft < 0))
+	if (unlikely((long)tmp_prefered_lft < 0))
 		tmp_prefered_lft = 0;
 	tmp_prefered_lft = min_t(__u32, ifp->prefered_lft, tmp_prefered_lft);
 	tmp_plen = ifp->prefix_len;
