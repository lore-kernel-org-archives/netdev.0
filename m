From: pablo@netfilter.org
Subject: [PATCH 0/8] netfilter updates for 3.4-rc5
Date: Mon, 30 Apr 2012 17:16:47 +0200
Message-ID: <1335799015-2003-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David!

This patchset contains the following fixes:

* One fix in the initialization path of the IPVS modules spotted by
  the the trinity syscall fuzz testing tool from Sasha Levin.

* Three patches to address more weak/buggy error handling in the
  initialization path of the IPVS modules from Hans Schillinstrom.

* Fix a regression in the initialization path of ipvs_ctl (introduced in
  2.6.39) due from Julian Anastasov.

* A couple more initialization path robust error checkings from Julian
  Anastasov.

* One silly fix for xt_CT target for the case in which the new
  cttimeout infrastructure is not used, eg. --helper or --notrack,
  by myself.

You can pull these fixes from:

git://1984.lsi.us.es/net master

Thanks!

Hans Schillstrom (3):
  ipvs: null check of net->ipvs in lblc(r) shedulers
  ipvs: take care of return value from protocol init_netns
  ipvs: kernel oops - do_ip_vs_get_ctl

Julian Anastasov (3):
  ipvs: fix crash in ip_vs_control_net_cleanup on unload
  ipvs: add check in ftp for initialized core
  ipvs: reset ipvs pointer in netns

Pablo Neira Ayuso (1):
  netfilter: xt_CT: fix wrong checking in the timeout assignment path

Sasha Levin (1):
  ipvs: Verify that IP_VS protocol has been registered

 include/net/ip_vs.h                   |    4 ++-
 net/netfilter/ipvs/ip_vs_core.c       |   11 +++++++
 net/netfilter/ipvs/ip_vs_ctl.c        |   56 +++++++++++++++++++--------------
 net/netfilter/ipvs/ip_vs_ftp.c        |    2 ++
 net/netfilter/ipvs/ip_vs_lblc.c       |    3 ++
 net/netfilter/ipvs/ip_vs_lblcr.c      |    3 ++
 net/netfilter/ipvs/ip_vs_proto.c      |   38 +++++++++++++++-------
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    5 ++-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |    5 ++-
 net/netfilter/ipvs/ip_vs_proto_udp.c  |    5 ++-
 net/netfilter/xt_CT.c                 |    2 +-
 11 files changed, 94 insertions(+), 40 deletions(-)

-- 
1.7.9.5

