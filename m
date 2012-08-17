From: pablo@netfilter.org
Subject: [PATCH 0/5] netfilter fixes for 3.6-rc
Date: Fri, 17 Aug 2012 16:09:28 +0200
Message-ID: <1345212573-3076-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48108 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752117Ab2HQOKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2012 10:10:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following five patches contain fixes for 3.6-rc, they are:

* Two fixes for message parsing in the SIP conntrack helper, from
  Patrick McHardy.

* One fix for the SIP helper introduced in the user-space cthelper
  infrastructure, from Patrick McHardy.

* fix missing appropriate locking while modifying one conntrack entry
  from the nfqueue integration code, from myself.

* fix possible access to uninitiliazed timer in the nf_conntrack
  expectation infrastructure, from myself.

You can pull these changes from:

git://1984.lsi.us.es/nf

Thanks!

Pablo Neira Ayuso (2):
  netfilter: ctnetlink: fix missing locking while changing conntrack from nfqueue
  netfilter: nf_ct_expect: fix possible access to uninitialized timer

Patrick McHardy (3):
  netfilter: nf_ct_sip: fix helper name
  netfilter: nf_ct_sip: fix IPv6 address parsing
  netfilter: nf_nat_sip: fix via header translation with multiple parameters

 include/linux/netfilter/nf_conntrack_sip.h |    2 +-
 net/ipv4/netfilter/nf_nat_sip.c            |    9 +--
 net/netfilter/nf_conntrack_expect.c        |   29 ++-------
 net/netfilter/nf_conntrack_netlink.c       |    7 ++-
 net/netfilter/nf_conntrack_sip.c           |   92 ++++++++++++++++++++++------
 5 files changed, 90 insertions(+), 49 deletions(-)

-- 
1.7.10.4
