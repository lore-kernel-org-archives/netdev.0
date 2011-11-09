From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 0/4] netfilter reverse path filter matches
Date: Wed,  9 Nov 2011 23:19:44 +0100
Message-ID: <1320877188-1972-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Version 3 of the ipv4/v6 reverse path filter matches discussed
during nfws 2011.

Major change since v2 is that the ipv4 version no longer tries
to determine the (likely) input interface for the reverse test.

To obtain that information, an additional lookup would be
required (first obtain oif, then use that oif as iif in the
reversed lookup -- this is what the existing rpf in fib_validate_source()
does).
While its certainly possible to mimic fib_validate_source more closely,
doing so has certain side effects:
- either pay additonal rt lookup cost
- or, attach the input route early on ourselves, so ipv4 stack does
  not need to do it (which can then cause strange effects when using
  policy routing, as marking in pre-routing has no effect when done
  after -m rpfilter ...)

2nd change is a new "--invert" flag to permit one-line dropping
("-m rpfilter --invert -j DROP") of packets that failed the reverse
path lookup test.

Userspace part is stored in my iptables repository on
http://git.breakpoint.cc/cgi-bin/gitweb.cgi?p=fw/iptables.git (branch 'xt_rpfilter_9').

Kernel patches are located in the 'xt_rpfilter_9' branch on
http://git.breakpoint.cc/cgi-bin/gitweb.cgi?p=fw/nf-next.git.

Patches will be sent as followup to this email.

Summary of changes:

The following changes since commit e56c57d0d3fdbbdf583d3af96bfb803b8dfa713e:

net: rename sk_clone to sk_clone_lock (2011-11-08 17:07:07 -0500)

are available in the git repository at:
git://git.breakpoint.cc/fw/nf-next.git xt_rpfilter_9

Florian Westphal (4):
  net: ipv4: export fib_lookup and fib_table_lookup
  netfilter: add ipv4 reverse path filter match
  ipv6: add ip6_route_lookup
  netfilter: add ipv6 reverse path filter match

include/linux/netfilter/xt_rpfilter.h |   23 ++++++
include/net/ip6_route.h               |    2 +
net/ipv4/fib_rules.c                  |    1 +
net/ipv4/fib_trie.c                   |    1 +
net/ipv4/netfilter/Kconfig            |   10 +++
net/ipv4/netfilter/Makefile           |    1 +
net/ipv4/netfilter/ipt_rpfilter.c     |  141 +++++++++++++++++++++++++++++++++
net/ipv6/netfilter/Kconfig            |   10 +++
net/ipv6/netfilter/Makefile           |    1 +
net/ipv6/netfilter/ip6t_rpfilter.c    |  133 +++++++++++++++++++++++++++++++
net/ipv6/route.c                      |    7 ++
11 files changed, 330 insertions(+), 0 deletions(-)
create mode 100644 include/linux/netfilter/xt_rpfilter.h
create mode 100644 net/ipv4/netfilter/ipt_rpfilter.c
create mode 100644 net/ipv6/netfilter/ip6t_rpfilter.c
