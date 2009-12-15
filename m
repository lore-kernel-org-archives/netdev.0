From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/05: netfilter fixes
Date: Tue, 15 Dec 2009 17:14:27 +0100 (MET)
Message-ID: <20091215161426.4146.55284.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

the following patches fix a couple of bugs in netfilter and IPVS:

- a fix for a crash triggered by fragmentes received by bridge netfilter being
  combined with fragments received on non-bridge devices from myself

- a fix for IPVS synchronization on connection close from Xiaotian Feng

- a fix for use of uninitialized fields in IPVS from Simon Horman

- a patch to document the minimal required iptables version from Jan Engelhardt

I'll also push the fragment fix to stable (forgot to add CC before committing)
once it hits mainline.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!


 Documentation/Changes                          |    2 ++
 include/net/ip.h                               |    1 +
 include/net/ipv6.h                             |    8 ++++++++
 include/net/netfilter/ipv6/nf_conntrack_ipv6.h |    2 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c            |   21 +++++++++++++++++----
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   19 +++++++++++++++++--
 net/ipv6/netfilter/nf_conntrack_reasm.c        |    7 ++++---
 net/ipv6/reassembly.c                          |    5 ++++-
 net/netfilter/ipvs/ip_vs_core.c                |    1 +
 net/netfilter/ipvs/ip_vs_ctl.c                 |    4 ++++
 10 files changed, 59 insertions(+), 11 deletions(-)

Jan Engelhardt (1):
      netfilter: xtables: document minimal required version

Patrick McHardy (2):
      ipv6: reassembly: use seperate reassembly queues for conntrack and local delivery
      netfilter: fix crashes in bridge netfilter caused by fragment jumps

Simon Horman (1):
      ipvs: zero usvc and udest

Xiaotian Feng (1):
      ipvs: fix synchronization on connection close
