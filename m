From: pablo@netfilter.org
Subject: [PATCH 0/4] netfilter updates for net tree
Date: Tue, 17 Jan 2012 12:04:45 +0100
Message-ID: <1326798289-11592-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:32779 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303Ab2AQLFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 06:05:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi Dave,

The following patches contains updates for your current net tree:

* A couple for bugfixes for ipset from Jozsef.

* Revert the user-space expectation helper support from myself.
  I decided to do this because I found problems specifically
  regarding NAT setups. I didn't throw the towel though. I'm
  working one new infrastructure. My plan is to submit it for
  net-next once it's open and it passes developers scrutiny
  (still work in progress):

 http://1984.lsi.us.es/git/net-next/commit/?h=cthelper&id=4e690f548859eec5a3dad151dec9c12bac17c014

* Fix one compilation warning if ip6tables is disabled in
  xt_hashlimit.

You can pull these changes from:

git://1984.lsi.us.es/net nf

Thanks.

Jozsef Kadlecsik (2):
  netfilter: ipset: autoload set type modules safely
  netfilter: ipset: dumping error triggered removing references twice

Pablo Neira Ayuso (1):
  netfilter: revert user-space expectation helper support

Stephen Rothwell (1):
  netfilter: xt_hashlimit: fix unused variable warning if IPv6 disabled

 include/linux/netfilter/nf_conntrack_common.h |    4 ---
 include/linux/netfilter/xt_CT.h               |    3 +-
 net/netfilter/ipset/ip_set_core.c             |   37 ++++++++++++++++++-------
 net/netfilter/nf_conntrack_helper.c           |   12 --------
 net/netfilter/nf_conntrack_netlink.c          |    4 ---
 net/netfilter/xt_CT.c                         |    8 ++---
 net/netfilter/xt_hashlimit.c                  |    5 +++-
 7 files changed, 35 insertions(+), 38 deletions(-)

-- 
1.7.7.3
