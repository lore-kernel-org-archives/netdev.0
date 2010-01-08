From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/04: netfilter fixes
Date: Fri,  8 Jan 2010 17:42:07 +0100 (MET)
Message-ID: <20100108164204.28066.44430.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

the following patches fix a couple of bugs in netfilter and IPVS:

- use lib/gcd in IPVS

- add missing boundary checks for IPVS ioctl arguments, from Arjan

- fix an out-of-bounds read in FTP conntrack, from myself

- add missing CAP_NET_ADMIN check to ebtables, from Florian Westphal.
  ebtables userspace uses IP RAW sockets to address ebtables, which
  enforce CAP_NET_RAW. Any other IP socket type allows unpriviledged
  access to the ebtables ruleset.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!


 net/bridge/netfilter/ebtables.c  |    6 ++++++
 net/netfilter/ipvs/Kconfig       |    3 ++-
 net/netfilter/ipvs/ip_vs_ctl.c   |   14 +++++++++++++-
 net/netfilter/ipvs/ip_vs_wrr.c   |   15 +--------------
 net/netfilter/nf_conntrack_ftp.c |   18 +++++++++---------
 5 files changed, 31 insertions(+), 25 deletions(-)

Arjan van de Ven (1):
      ipvs: Add boundary check on ioctl arguments

Florian Fainelli (1):
      ipvs: ip_vs_wrr.c: use lib/gcd.c

Florian Westphal (1):
      netfilter: ebtables: enforce CAP_NET_ADMIN

Patrick McHardy (1):
      netfilter: nf_ct_ftp: fix out of bounds read in update_nl_seq()
