From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/09: netfilter fixes/trivial patches
Date: Mon, 12 Jan 2009 11:05:59 +0100 (MET)
Message-ID: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

the following patches contain fixes for a number of netfilter bugs:

- Herbert's patches to fix VLAN/PPPoE handling in bridge netfilter

- a fix for an iptables regression in 2.6.28, breaking revision queries
  for match and target revisions

- a fix for an ebtables regression in 2.6.28, which inverted the
  meaning of match result codes

- a fix for a problem with the ICMP/ICMPv6 conntrack timeout sysctls
  on big-endian

Additionally it includes four trivial patches that don't seem worth
queueing for the next merge window:

- removal of the "happy cracking" and similar messages

- simplification of nf_conntrack_alloc() error handling

- addition of an informational message to the xt_time match

- reordering of struct xt_match to make it fit into a 128 byte cacheline

Feel free to ignore the last four patches in case you'd prefer to receive
them in the next merge window. The full patchset is also available in a
git tree at:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git

Please apply or pull, thanks.


 include/linux/netfilter/x_tables.h             |    2 +-
 net/bridge/br_netfilter.c                      |   18 ++++++++++++------
 net/bridge/netfilter/ebtables.c                |    2 +-
 net/ipv4/netfilter/iptable_filter.c            |    7 +------
 net/ipv4/netfilter/iptable_mangle.c            |    6 +-----
 net/ipv4/netfilter/iptable_raw.c               |    6 +-----
 net/ipv4/netfilter/iptable_security.c          |    6 +-----
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    5 +----
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +-
 net/netfilter/nf_conntrack_core.c              |    4 ++--
 net/netfilter/nf_conntrack_netlink.c           |    2 +-
 net/netfilter/x_tables.c                       |    8 ++++++++
 net/netfilter/xt_time.c                        |   11 +++++++++++
 14 files changed, 43 insertions(+), 38 deletions(-)

Herbert Xu (2):
      netfilter: bridge: Fix handling of non-IP packets in FORWARD/POST_ROUTING
      netfilter: bridge: Disable PPPOE/VLAN processing by default

Jan Engelhardt (2):
      netfilter: ebtables: fix inversion in match code
      netfilter: xt_time: print timezone for user information

Julia Lawall (1):
      netfilter: simplify nf_conntrack_alloc() error handling

Patrick McHardy (3):
      netfilter: remove "happy cracking" message
      netfilter: x_tables: fix match/target revision lookup
      netfilter: nf_conntrack: fix ICMP/ICMPv6 timeout sysctls on big-endian

Richard Kennedy (1):
      netfilter: remove padding from struct xt_match on 64bit builds
