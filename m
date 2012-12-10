From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next:master 195/198] net/bridge/br_mdb.c:79:35: sparse:
 incompatible types in comparison expression (different address spaces)
Date: Mon, 10 Dec 2012 20:44:11 +0800
Message-ID: <1355143451.11752.20.camel@cr0>
References: <50c3fd5e.qB65a7/5e+IZT2ix%fengguang.wu@intel.com>
	 <1355143004.11752.19.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9850 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751620Ab2LJMoS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 07:44:18 -0500
In-Reply-To: <1355143004.11752.19.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-12-10 at 20:36 +0800, Cong Wang wrote:
> On Sun, 2012-12-09 at 10:54 +0800, kbuild test robot wrote:
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> > head:   9ecb9aabaf634677c77af467f4e3028b09d7bcda
> > commit: ee07c6e7a6f8a25c18f0a6b18152fbd7499245f6 [195/198] bridge: export multicast database via netlink
> > 
> > 
> > sparse warnings:
> > 
> > + net/bridge/br_mdb.c:79:35: sparse: incompatible types in comparison expression (different address spaces)
> 
> Hi, Fengguang,
> 
> I am not sure if I understand this warning correctly. Does the following
> patch fix it?
> 

Hmm, no, probably this one:

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 2528328..cd6735c 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -63,7 +63,7 @@ static int br_mdb_fill_info(struct sk_buff *skb,
struct netlink_callback *cb,
        for (i = 0; i < mdb->max; i++) {
                struct hlist_node *h;
                struct net_bridge_mdb_entry *mp;
-               struct net_bridge_port_group *p, **pp;
+               struct net_bridge_port_group  __rcu *p, **pp;
                struct net_bridge_port *port;
 
                hlist_for_each_entry_rcu(mp, h, &mdb->mhash[i],
hlist[mdb->ver]) {
