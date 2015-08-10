From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/5] Netfilter fixes for net
Date: Mon, 10 Aug 2015 19:58:34 +0200
Message-ID: <1439229519-7640-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains five Netfilter fixes for your net tree,
they are:

1) Silence a warning on falling back to vmalloc(). Since 88eab472ec21, we can
   easily hit this warning message, that gets users confused. So let's get rid
   of it.

2) Recently when porting the template object allocation on top of kmalloc to
   fix the netns dependencies between x_tables and conntrack, the error
   checks where left unchanged. Remove IS_ERR() and check for NULL instead.
   Patch from Dan Carpenter.

3) Don't ignore gfp_flags in the new nf_ct_tmpl_alloc() function, from
   Joe Stringer.

4) Fix a crash due to NULL pointer dereference in ip6t_SYNPROXY, patch from
   Phil Sutter.

5) The sequence number of the Syn+ack that is sent from SYNPROXY to clients is
   not adjusted through our NAT infrastructure, as a result the client may
   ignore this TCP packet and TCP flow hangs until the client probes us.  Also
   from Phil Sutter.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 15f1bb1f1e067be7088ed43ef23d59629bd24348:

  qlcnic: Fix corruption while copying (2015-07-29 23:57:26 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 3c16241c445303a90529565e7437e1f240acfef2:

  netfilter: SYNPROXY: fix sending window update to client (2015-08-10 13:55:07 +0200)

----------------------------------------------------------------
Dan Carpenter (1):
      netfilter: nf_conntrack: checking for IS_ERR() instead of NULL

Joe Stringer (1):
      netfilter: conntrack: Use flags in nf_ct_tmpl_alloc()

Pablo Neira Ayuso (1):
      netfilter: nf_conntrack: silence warning on falling back to vmalloc()

Phil Sutter (2):
      netfilter: ip6t_SYNPROXY: fix NULL pointer dereference
      netfilter: SYNPROXY: fix sending window update to client

 net/ipv4/netfilter/ipt_SYNPROXY.c  |    3 ++-
 net/ipv6/netfilter/ip6t_SYNPROXY.c |   19 +++++++++++--------
 net/netfilter/nf_conntrack_core.c  |    8 +++-----
 net/netfilter/nf_synproxy_core.c   |    4 +---
 net/netfilter/xt_CT.c              |    5 +++--
 5 files changed, 20 insertions(+), 19 deletions(-)
