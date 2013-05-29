From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/5] netfilter fixes for 3.10-rc3
Date: Wed, 29 May 2013 18:03:08 +0200
Message-ID: <1369843394-24251-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter/IPVS fixes for 3.10-rc3,
they are:

* fix xt_addrtype with IPv6, from Florian Westphal. This required
  a new hook for IPv6 functions in the netfilter core to avoid
  hard dependencies with the ipv6 subsystem when this match is
  only used for IPv4.

* fix connection reuse case in IPVS. Currently, if an reused
  connection are directed to the same server. If that server is
  down, those connection would fail. Therefore, clear the
  connection and choose a new server among the available ones.

* fix possible non-nul terminated string sent to user-space if
  ipt_ULOG is used as the default netfilter logging stub, from
  Chen Gang.

* fix mark logging of IPv6 packets in xt_LOG, from Michal Kubecek.
  This bug has been there since 2.6.26.

* Fix breakage ip_vs_sh due to incorrect structure layout for
  RCU, from Jan Beulich.

The following changes since commit 497574c72c9922cf20c12aed15313c389f72=
2fa0:

  xfrm: properly handle invalid states as an error (2013-05-23 01:20:07=
 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to a70b9641e6a90d6821e4354a2c2fede74015db29=
:

  ipvs: ip_vs_sh: fix build (2013-05-29 17:50:39 +0200)

----------------------------------------------------------------
Chen Gang (1):
      netfilter: ipt_ULOG: fix non-null terminated string in the nf_log=
 path

=46lorian Westphal (1):
      netfilter: add nf_ipv6_ops hook to fix xt_addrtype with IPv6

Grzegorz Lyczba (1):
      ipvs: Fix reuse connection if real server is dead

Jan Beulich (1):
      ipvs: ip_vs_sh: fix build

Michal Kube=C4=8Dek (1):
      netfilter: xt_LOG: fix mark logging for IPv6 packets

 include/linux/netfilter_ipv6.h  |   16 ++++++++++++++++
 include/net/addrconf.h          |    2 +-
 net/ipv4/netfilter/ipt_ULOG.c   |    6 ++++--
 net/ipv6/addrconf.c             |    2 +-
 net/ipv6/netfilter.c            |    7 +++++++
 net/netfilter/core.c            |    2 ++
 net/netfilter/ipvs/ip_vs_core.c |   35 +++++++++++++++++++++++++++++++=
++++
 net/netfilter/ipvs/ip_vs_sh.c   |    2 +-
 net/netfilter/xt_LOG.c          |    2 +-
 net/netfilter/xt_addrtype.c     |   27 ++++++++++++++++-----------
 10 files changed, 84 insertions(+), 17 deletions(-)

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
