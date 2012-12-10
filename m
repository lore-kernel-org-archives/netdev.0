From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next:master 195/198] net/bridge/br_mdb.c:79:35: sparse:
 incompatible types in comparison expression (different address spaces)
Date: Mon, 10 Dec 2012 20:36:44 +0800
Message-ID: <1355143004.11752.19.camel@cr0>
References: <50c3fd5e.qB65a7/5e+IZT2ix%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60016 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750963Ab2LJMgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 07:36:50 -0500
In-Reply-To: <50c3fd5e.qB65a7/5e+IZT2ix%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-12-09 at 10:54 +0800, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   9ecb9aabaf634677c77af467f4e3028b09d7bcda
> commit: ee07c6e7a6f8a25c18f0a6b18152fbd7499245f6 [195/198] bridge: export multicast database via netlink
> 
> 
> sparse warnings:
> 
> + net/bridge/br_mdb.c:79:35: sparse: incompatible types in comparison expression (different address spaces)

Hi, Fengguang,

I am not sure if I understand this warning correctly. Does the following
patch fix it?

Thanks!

---------------->

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 2528328..0bc0e13 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -77,7 +77,7 @@ static int br_mdb_fill_info(struct sk_buff *skb,
struct netlink_callback *cb,
                        }
 
                        for (pp = &mp->ports;
-                            (p = rcu_dereference(*pp)) != NULL;
+                            (p = rcu_dereference_protected(*pp, 1)) !=
NULL;
                              pp = &p->next) {
                                port = p->port;
                                if (port) {
