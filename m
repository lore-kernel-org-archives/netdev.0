From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 0/9] v2 ipv4/ipv6 refcount conversions
Date: Tue,  4 Jul 2017 09:34:53 +0300
Message-ID: <1499150102-7478-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        steffen.klassert@secunet.com, kuznet@ms2.inr.ac.ru,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes in v2:
 * rebase on top of net-next
 * currently by default refcount_t = atomic_t (*) and uses all 
   atomic standard operations unless CONFIG_REFCOUNT_FULL is enabled.
   This is a compromise for the systems that are critical on
   performance (such as net) and cannot accept even slight delay
   on the refcounter operations.

This series, for ipv4/ipv6 network components, replaces atomic_t reference
counters with the new refcount_t type and API (see include/linux/refcount.h).
By doing this we prevent intentional or accidental
underflows or overflows that can led to use-after-free vulnerabilities.

The patches are fully independent and can be cherry-picked separately.
In order to try with refcount functionality enabled in run-time,
CONFIG_REFCOUNT_FULL must be enabled.

NOTE: automatic kernel builder for some reason doesn't like all my
network branches and regularly times out the builds on these branches.
Suggestion for "waiting a day for a good coverage" doesn't work, as
we have seen with generic network conversions. So please wait for the
full report from kernel test rebot before merging further up.
This has been compile-tested in 116 configs, but 71 timed out (including
all s390-related configs again). I am trying to see if they can fix
build coverage for me in meanwhile.

* The respective change is currently merged into -next as
  "locking/refcount: Create unchecked atomic_t implementation".

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
