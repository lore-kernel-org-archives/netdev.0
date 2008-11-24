From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/03: netfilter fixes
Date: Mon, 24 Nov 2008 14:44:35 +0100 (MET)
Message-ID: <20081124134427.462.77824.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

the following three patches for 2.6.28 fix a couple of netfilter issues:

- a conntrack creation race in ctnetlink that can cause NULL pointer
  dereferences in ctnetlink and duplicate conntrack entries.

- a missing const qualifier that got lost during the encapsulation of
  iptables target parameters

- a crash with bridge netfilter and GRE caused by a missing update_pmtu()
  function for the fake dst_entry.

Please apply, thanks.


 include/linux/netfilter/x_tables.h   |    2 +-
 net/bridge/br_netfilter.c            |   13 +++++++++++++
 net/netfilter/nf_conntrack_core.c    |    2 --
 net/netfilter/nf_conntrack_netlink.c |    5 +++--
 4 files changed, 17 insertions(+), 5 deletions(-)

Herbert Xu (1):
      bridge: netfilter: fix update_pmtu crash with GRE

Jan Engelhardt (1):
      netfilter: xtables: add missing const qualifier to xt_tgchk_param

Patrick McHardy (1):
      netfilter: ctnetlink: fix conntrack creation race
