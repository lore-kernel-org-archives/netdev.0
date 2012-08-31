From: pablo@netfilter.org
Subject: [PATCH 0/6] netfilter updates for 3.6-rc
Date: Fri, 31 Aug 2012 16:03:03 +0200
Message-ID: <1346421789-3449-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54060 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753782Ab2HaOEZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 10:04:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contain fixes for your net tree, they are:

* Fix wrong type for NFULA_HWTYPE attribute, this was introduced while
  removing the NLA_PUT macro, from Patrick McHardy.

* Three fixes that spot incorrect return values in the initialization
  path of several Netfilter modules, from Julia Lawall.

* Fix crash in the SIP helper if we hit EBUSY while adding the RTCP
  expectation, from myself.

* Fix racy timer handling in case conntrackd is running in reliable
  event mode, also from myself.

You can pull these changes from:

git://1984.lsi.us.es/nf master

BTW, please merge net to net-next after this so I can resolve the
conflict between the SIP helper and NAT IPv6 changes from Patrick,
which is scheduled for net-next.

Thanks!

Julia Lawall (3):
  ipvs: fix error return code
  netfilter: ctnetlink: fix error return code in init path
  netfilter: nfnetlink_log: fix error return code in init path

Pablo Neira Ayuso (2):
  netfilter: nf_nat_sip: fix incorrect handling of EBUSY for RTCP expectation
  netfilter: nf_conntrack: fix racy timer handling with reliable events

Patrick McHardy (1):
  netfilter: nfnetlink_log: fix NLA_PUT macro removal bug

 include/net/netfilter/nf_conntrack_ecache.h |    1 +
 net/ipv4/netfilter/nf_nat_sip.c             |    5 ++++-
 net/netfilter/ipvs/ip_vs_ctl.c              |    4 +++-
 net/netfilter/nf_conntrack_core.c           |   16 +++++++++++-----
 net/netfilter/nf_conntrack_netlink.c        |    3 ++-
 net/netfilter/nfnetlink_log.c               |    6 ++++--
 6 files changed, 25 insertions(+), 10 deletions(-)

-- 
1.7.10.4
