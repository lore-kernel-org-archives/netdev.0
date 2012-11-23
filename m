From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 23 Nov 2012 15:18:40 -0500 (EST)
Message-ID: <20121123.151840.96136627506681502.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Networking bug fixes, Cacio e Pepe edition:

1) BNX2X accidently accesses chip rev specific registers without
   an appropriate guard, fix from Ariel Elior.

2) When we removed the routing cache, we set ip_rt_max_size to
   ~0 just to keep reporting a value to userspace via sysfs.
   But the ipv4 IPSEC layer was using this to tune itself which
   is completely bogus to now do.  Fix from Steffen Klassert.

3) Missing initialization in netfilter ipset code from Jozsef
   Kadlecsik.

4) Check CTA_TIMEOUT_NAME length properly in netfilter cttimeout code,
   fix from Florian Westphal.

5) After removing the routing cache, we inadvertantly are caching
   multicast routes that end up looping back locally, we cannot do
   that legitimately any more.  Fix from Julian Anastasov.

6) Revert a race fix for 8139cp qemu/kvm that doesn't actually work
   properly on real hardware.  From Francois Romieu.

7) Fixup errors in example command lines in VXLAN device docs.

Please pull, thanks a log!

The following changes since commit ef6c5be658f6a70c1256fbd18e18ee0dc24c=
3386:

  fix incorrect NR_FREE_PAGES accounting (appears like memory leak) (20=
12-11-21 12:33:16 -1000)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 4a25417c20fac00b3afd58ce27408f964d19e708=
:

  bnx2x: remove redundant warning log (2012-11-23 14:17:36 -0500)

----------------------------------------------------------------
Ariel Elior (1):
      bnx2x: remove redundant warning log

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'master' of git://1984.lsi.us.es/nf

=46lorian Westphal (1):
      netfilter: cttimeout: fix buffer overflow

Jozsef Kadlecsik (1):
      netfilter: ipset: Fix range bug in hash:ip,port,net

Julian Anastasov (1):
      ipv4: do not cache looped multicasts

Steffen Klassert (1):
      xfrm: Fix the gc threshold value for ipv4

Zhi Yong Wu (1):
      vxlan: fix command usage in its doc

fran=E7ois romieu (1):
      8139cp: revert "set ring address before enabling receiver"

 Documentation/networking/vxlan.txt               |  4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 11 +++++++----
 drivers/net/ethernet/realtek/8139cp.c            | 22 +++++++++++-----=
------
 include/net/xfrm.h                               |  2 +-
 net/ipv4/route.c                                 |  9 ++++++---
 net/ipv4/xfrm4_policy.c                          | 13 +------------
 net/netfilter/ipset/ip_set_hash_ip.c             |  4 ++--
 net/netfilter/ipset/ip_set_hash_ipport.c         |  7 +++----
 net/netfilter/ipset/ip_set_hash_ipportip.c       |  7 +++----
 net/netfilter/ipset/ip_set_hash_ipportnet.c      |  7 +++++--
 net/netfilter/nfnetlink_cttimeout.c              |  3 ++-
 11 files changed, 43 insertions(+), 46 deletions(-)
