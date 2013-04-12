From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/4] netfilter fixes for net
Date: Fri, 12 Apr 2013 12:13:15 +0200
Message-ID: <1365761599-6990-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains late netfilter fixes for your net
tree, they are:

* Don't drop segmented TCP packets in the SIP helper, we've got reports
  from users that this was breaking communications when the SIP phone
  messages are larger than the MTU, from Patrick McHardy.

* Fix refcount leak in the ipset list set, from Jozsef Kadlecsik.

* On hash set resizing, the nomatch flag was lost, thus entirely inverting
  the logic of the set matching, from Jozsef Kadlecsik.

* Fix crash on NAT modules removal. Timer expiration may race with the
  module cleanup exit path while deleting conntracks, from Florian
  Westphal.

The following changes since commit 53f63189b1110559dce8c1ee29e8abc3e31f7630:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-04-05 14:04:10 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to c2d421e171868586939c328dfb91bab840fe4c49:

  netfilter: nf_nat: fix race when unloading protocol modules (2013-04-12 11:46:31 +0200)

Please, consider pulling this.
Thanks!

P.S: Jozsef has several updates for net-next that depend on these fixes,
could you pull from your net tree into your net-next tree, please? Thanks.

----------------------------------------------------------------
Florian Westphal (1):
      netfilter: nf_nat: fix race when unloading protocol modules

Jozsef Kadlecsik (2):
      netfilter: ipset: list:set: fix reference counter update
      netfilter: ipset: hash:*net*: nomatch flag not excluded on set resize

Patrick McHardy (1):
      netfilter: nf_ct_sip: don't drop packets with offsets pointing outside the packet

 include/linux/netfilter/ipset/ip_set_ahash.h |   30 ++++++++++++++-----
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |   18 ++++++++++++
 net/netfilter/ipset/ip_set_hash_net.c        |   22 ++++++++++++--
 net/netfilter/ipset/ip_set_hash_netiface.c   |   22 ++++++++++++--
 net/netfilter/ipset/ip_set_hash_netport.c    |   18 ++++++++++++
 net/netfilter/ipset/ip_set_list_set.c        |   10 +++++--
 net/netfilter/nf_conntrack_sip.c             |    6 ++--
 net/netfilter/nf_nat_core.c                  |   40 +++++---------------------
 8 files changed, 115 insertions(+), 51 deletions(-)

