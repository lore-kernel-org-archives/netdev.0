From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 0/9] net, ipv4, ipv6 refcounter conversions
Date: Thu, 16 Mar 2017 20:23:22 +0200
Message-ID: <1489688611-4542-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        steffen.klassert@secunet.com, kuznet@ms2.inr.ac.ru,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series, for ipv4/ipv6 components, replaces atomic_t reference
counters with the new refcount_t type and API (see include/linux/refcount.h).
By doing this we prevent intentional or accidental
underflows or overflows that can led to use-after-free vulnerabilities.

The patches are fully independent and can be cherry-picked separately.
If there are no objections to the patches, please merge them via respective trees.

Elena Reshetova (9):
  net, ipv6: convert ipv6_txoptions.refcnt from atomic_t to refcount_t
  net, ipv6: convert inet6_dev.refcnt from atomic_t to refcount_t
  net, ipv6: convert inet6_ifaddr.refcnt from atomic_t to refcount_t
  net, ipv6: convert ifmcaddr6.mca_refcnt from atomic_t to refcount_t
  net, ipv6: convert ifacaddr6.aca_refcnt from atomic_t to refcount_t
  net, ipv6: convert xfrm6_tunnel_spi.refcnt from atomic_t to refcount_t
  net, ipv6: convert ip6addrlbl_entry.refcnt from atomic_t to refcount_t
  net, ipv4: convert cipso_v4_doi.refcount from atomic_t to refcount_t
  net, ipv4: convert fib_info.fib_clntref from atomic_t to refcount_t

 include/net/addrconf.h   | 14 +++++++-------
 include/net/cipso_ipv4.h |  3 ++-
 include/net/if_inet6.h   |  9 +++++----
 include/net/ip_fib.h     |  7 ++++---
 include/net/ipv6.h       |  7 ++++---
 net/ipv4/cipso_ipv4.c    | 12 ++++++------
 net/ipv4/fib_semantics.c |  2 +-
 net/ipv4/fib_trie.c      |  2 +-
 net/ipv6/addrconf.c      |  4 ++--
 net/ipv6/addrlabel.c     |  9 +++++----
 net/ipv6/anycast.c       |  6 +++---
 net/ipv6/exthdrs.c       |  4 ++--
 net/ipv6/ipv6_sockglue.c |  2 +-
 net/ipv6/mcast.c         | 18 +++++++++---------
 net/ipv6/xfrm6_tunnel.c  |  8 ++++----
 15 files changed, 56 insertions(+), 51 deletions(-)

-- 
2.7.4
