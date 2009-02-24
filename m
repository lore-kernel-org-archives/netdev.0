From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/06: netfilter fixes
Date: Tue, 24 Feb 2009 15:52:44 +0100 (MET)
Message-ID: <20090224145243.9789.60678.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34667 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756685AbZBXOwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 09:52:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

the following patches contain netfilter fixes for 2.6.29:

- a typo fix in a ICMPv6 conntrack log message from Eric Leblond

- a fix for nfnetlink_log per-rule threshold overrides. Currently the
  rule always wins because of the defaults, which is not intended.
  Also from Eric.

- a fix for the nfnetlink_log default timeout units from Eric. The
  kernel uses 10ms units, the default is specified in HZ.

- a fix to avoid conntrack event delivery for untracked connections

- a regression fix from Jan for a problem introduced in 2.6.28: the
  /proc/net/ip_tables_matches and similar files don't include any
  module registered with NFPROTO_UNSPEC. Unfortunately quite large.

- another regression fix from the kernel.org bugzilla: proc file
  addition and removal of IPv4 addresses in recent match have ben
  broken since the addition of IPv6 support.

The patches are also available in my nf-2.6.git tree at:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git

I've created it according to your suggestions, I hope everything is fine.
A small warning though: since its based on Linus' tree, it contains a lot
of commits not in net-2.6.git yet.

Please apply or pull, thanks.


 include/linux/netfilter/xt_NFLOG.h             |    2 +-
 include/net/netfilter/nf_conntrack_core.h      |    2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    5 +-
 net/netfilter/nfnetlink_log.c                  |    8 +-
 net/netfilter/x_tables.c                       |  199 +++++++++++++++++-------
 net/netfilter/xt_recent.c                      |    2 +-
 6 files changed, 153 insertions(+), 65 deletions(-)

Eric Leblond (3):
      netfilter: nf_conntrack_ipv6: fix nf_log_packet message in icmpv6 conntrack
      netfilter: nfnetlink_log: fix per-rule qthreshold override
      netfilter: nfnetlink_log: fix timeout handling

Jan Engelhardt (1):
      netfilter: make proc/net/ip* print names from foreign NFPROTO

Josef Drexler (1):
      netfilter: xt_recent: fix proc-file addition/removal of IPv4 addresses

Patrick McHardy (1):
      netfilter: nf_conntrack: don't try to deliver events for untracked connections
