From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/17] netfilter/ipvs updates for net-next
Date: Mon, 24 Nov 2014 14:27:37 +0100
Message-ID: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44831 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753751AbaKXNZu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2014 08:25:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter updates for your net-next
tree, this includes the NAT redirection support for nf_tables, the
cgroup support for nft meta and conntrack zone support for the connlimit
match. Coming after those, a bunch of sparse warning fixes, missing
netns bits and cleanups. More specifically, they are:

1) Prepare IPv4 and IPv6 NAT redirect code to use it from nf_tables,
   patches from Arturo Borrero.

2) Introduce the nf_tables redir expression, from Arturo Borrero.

3) Remove an unnecessary assignment in ip_vs_xmit/__ip_vs_get_out_rt().
   Patch from Alex Gartrell.

4) Add nft_log_dereference() macro to the nf_log infrastructure, patch
   from Marcelo Leitner.

5) Add some extra validation when registering logger families, also
   from Marcelo.

6) Some spelling cleanups from stephen hemminger.

7) Fix sparse warning in nf_logger_find_get().

8) Add cgroup support to nf_tables meta, patch from Ana Rey.

9) A Kconfig fix for the new redir expression and fix sparse warnings in
   the new redir expression.

10) Fix several sparse warnings in the netfilter tree, from
    Florian Westphal.

11) Reduce verbosity when OOM in nfnetlink_log. User can basically do
    nothing when this situation occurs.

12) Add conntrack zone support to xt_connlimit, again from Florian.

13) Add netnamespace support to the h323 conntrack helper, contributed
    by Vasily Averin.

14) Remove unnecessary nul-pointer checks before free_percpu() and
    module_put(), from Markus Elfring.

15) Use pr_fmt in nfnetlink_log, again patch from Marcelo Leitner.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit b8901ac319768cdd3afa060787503e0c405f9607:

  ipx: remove __inline__ in c file on static (2014-10-27 16:25:31 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to beacd3e8ef237e077c8707395440813feef16d3f:

  netfilter: nfnetlink_log: Make use of pr_fmt where applicable (2014-11-20 14:09:01 +0100)

----------------------------------------------------------------
Alex Gartrell (1):
      ipvs: remove unnecessary assignment in __ip_vs_get_out_rt

Ana Rey (1):
      netfilter: nft_meta: add cgroup support

Arturo Borrero (3):
      netfilter: refactor NAT redirect IPv4 to use it from nf_tables
      netfilter: refactor NAT redirect IPv6 code to use it from nf_tables
      netfilter: nf_tables: add new expression nft_redir

Florian Westphal (2):
      netfilter: fix various sparse warnings
      netfilter: xt_connlimit: honor conntrack zone if available

Marcelo Leitner (3):
      netfilter: nf_log: Introduce nft_log_dereference() macro
      netfilter: log: protect nf_log_register against double registering
      netfilter: nfnetlink_log: Make use of pr_fmt where applicable

Markus Elfring (1):
      netfilter: Deletion of unnecessary checks before two function calls

Pablo Neira Ayuso (5):
      Merge branch 'ipvs-next'
      netfilter: nf_log: fix sparse warning in nf_logger_find_get()
      netfilter: fix unmet dependencies in NETFILTER_XT_TARGET_REDIRECT
      netfilter: nft_redir: fix sparse warnings
      netfilter: nfnetlink_log: remove unnecessary error messages

Vasily Averin (1):
      netfilter: nf_conntrack_h323: lookup route from proper net namespace

stephen hemminger (1):
      netfilter: fix spelling errors

 include/net/netfilter/ipv4/nf_nat_redirect.h |    9 +++
 include/net/netfilter/ipv6/nf_nat_redirect.h |    8 +++
 include/net/netfilter/nft_redir.h            |   21 ++++++
 include/uapi/linux/netfilter/nf_tables.h     |   18 +++++
 net/bridge/br_netfilter.c                    |    1 +
 net/ipv4/netfilter/Kconfig                   |   15 ++++
 net/ipv4/netfilter/Makefile                  |    2 +
 net/ipv4/netfilter/nf_log_arp.c              |   24 +++++--
 net/ipv4/netfilter/nf_log_ipv4.c             |   12 +++-
 net/ipv4/netfilter/nf_nat_redirect_ipv4.c    |   82 +++++++++++++++++++++
 net/ipv4/netfilter/nf_reject_ipv4.c          |    1 +
 net/ipv4/netfilter/nft_redir_ipv4.c          |   77 ++++++++++++++++++++
 net/ipv4/netfilter/nft_reject_ipv4.c         |    7 +-
 net/ipv6/netfilter/Kconfig                   |   15 ++++
 net/ipv6/netfilter/Makefile                  |    2 +
 net/ipv6/netfilter/nf_log_ipv6.c             |   12 +++-
 net/ipv6/netfilter/nf_nat_redirect_ipv6.c    |   75 +++++++++++++++++++
 net/ipv6/netfilter/nf_reject_ipv6.c          |    1 +
 net/ipv6/netfilter/nft_redir_ipv6.c          |   77 ++++++++++++++++++++
 net/ipv6/netfilter/nft_reject_ipv6.c         |    7 +-
 net/netfilter/Kconfig                        |   11 +++
 net/netfilter/Makefile                       |    1 +
 net/netfilter/core.c                         |    1 +
 net/netfilter/ipvs/ip_vs_ctl.c               |    3 +-
 net/netfilter/ipvs/ip_vs_pe.c                |    3 +-
 net/netfilter/ipvs/ip_vs_sched.c             |    3 +-
 net/netfilter/ipvs/ip_vs_sync.c              |    3 +-
 net/netfilter/ipvs/ip_vs_xmit.c              |    1 -
 net/netfilter/nf_conntrack_h323_main.c       |   14 ++--
 net/netfilter/nf_conntrack_helper.c          |    2 +-
 net/netfilter/nf_log.c                       |   40 ++++++-----
 net/netfilter/nf_tables_api.c                |    5 +-
 net/netfilter/nfnetlink_log.c                |   18 +++--
 net/netfilter/nft_meta.c                     |    7 ++
 net/netfilter/nft_redir.c                    |   99 ++++++++++++++++++++++++++
 net/netfilter/xt_DSCP.c                      |    6 +-
 net/netfilter/xt_REDIRECT.c                  |   84 ++--------------------
 net/netfilter/xt_connlimit.c                 |   25 ++++---
 38 files changed, 636 insertions(+), 156 deletions(-)
 create mode 100644 include/net/netfilter/ipv4/nf_nat_redirect.h
 create mode 100644 include/net/netfilter/ipv6/nf_nat_redirect.h
 create mode 100644 include/net/netfilter/nft_redir.h
 create mode 100644 net/ipv4/netfilter/nf_nat_redirect_ipv4.c
 create mode 100644 net/ipv4/netfilter/nft_redir_ipv4.c
 create mode 100644 net/ipv6/netfilter/nf_nat_redirect_ipv6.c
 create mode 100644 net/ipv6/netfilter/nft_redir_ipv6.c
 create mode 100644 net/netfilter/nft_redir.c
