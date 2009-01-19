From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/03: netfilter -stable fixes
Date: Mon, 19 Jan 2009 15:19:35 +0100 (MET)
Message-ID: <20090119141934.3312.15532.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net
To: stable@kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following three patches for -stable fix a number of netfilter
regressions:

- revision lookup for x_tables matches and targets registering with
  the new NFPROTO_UNSPEC is broken, causing failures when using
  features not offered by revision 0. New regression in 2.6.28.

- ebtables interprets return values from matches in the inverted
  sense. New regression in 2.6.28.

- the conntrack timeout sysctls for ICMP/ICMPv6 are broken on big
  endian due to a mismatch between the data type size and the size
  registered with the sysctls. Seems to be a regression from the
  switch from ip_conntrack to nf_conntrack.

Please apply, thanks.


 net/bridge/netfilter/ebtables.c                |    2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +-
 net/netfilter/x_tables.c                       |    8 ++++++++
 4 files changed, 11 insertions(+), 3 deletions(-)

Patrick McHardy (3):
      netfilter: x_tables: fix match/target revision lookup
      netfilter: ebtables: fix inversion in match code
      netfilter: nf_conntrack: fix ICMP/ICMPv6 timeout sysctls on big-endian
