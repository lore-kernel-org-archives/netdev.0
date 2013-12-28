From: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Subject: pull request [net]: batman-adv 2013-12-28
Date: Sat, 28 Dec 2013 17:05:53 +0100
Message-ID: <1388246760-3335-1-git-send-email-antonio@meshcoding.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hello David,

this is our "fixed" pull request intended for net/linux-3.13.

Here you have the same patches as before except for the netfilter patch that is
now using nf_reset() (as you suggested) and for a new patch that fixes the
access to the vlan_hdr in the rx path while reading the VID.


Short summary:

Patches from 1 to 5 take care of reshaping the packet layout a little bit to
make sure that all the structures we use for sending messages have size multiple
of 4 (or 2 when pack(2) is used).
This solves the problem raised by Russel King about the static checks in
batman-adv failing when compiling the module on the ARM architecture.


Patch 6 is adding the nf_reset() (as you suggested) after having removed the
batman-adv encapsulation header from a packet. This patch fixes the behaviour of
netfilter in case the skb enters two bridges during its life: once with the
batman-adv header and once without.
==> Please, enqueue this patch (number 6) for stable.


Patch 7 fixes a wrong access to the inner vlan_eth header when trying to read
the VID in the rx path.


Please pull or let me know of any problem.


Thank you,
	Antonio



The following changes since commit 6a9eadccff2926e392173a989042f14c867cffbf:

  ipv6: release dst properly in ipip6_tunnel_xmit (2013-12-27 13:14:40 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to 2b1e2cb3594df80446dc33bb8e12230da11f38ff:

  batman-adv: fix vlan header access (2013-12-28 14:48:40 +0100)

----------------------------------------------------------------
Included changes:

- reset netfilter-bridge state when removing the batman-adv
  header from an incoming packet. This prevents netfilter
  bridge from being fooled when the same packet enters a
  bridge twice (or more): the first time within the
  batman-adv header and the second time without.

- adjust the packet layout to prevent any architecture from
  adding padding bytes. All the structs sent over the wire
  now have size multiple of 4bytes (unless pack(2) is used).

- fix access to the inner vlan_eth header when reading the
  VID in the rx path.

----------------------------------------------------------------
Antonio Quartulli (4):
      batman-adv: fix size of batadv_icmp_header
      batman-adv: fix alignment for batadv_tvlv_tt_change
      batman-adv: clean nf state when removing protocol header
      batman-adv: fix vlan header access

Simon Wunderlich (3):
      batman-adv: fix alignment for batadv_coded_packet
      batman-adv: fix header alignment by unrolling batadv_header
      batman-adv: fix size of batadv_bla_claim_dst

 net/batman-adv/bat_iv_ogm.c            |  36 +++++-----
 net/batman-adv/distributed-arp-table.c |   6 +-
 net/batman-adv/fragmentation.c         |   8 +--
 net/batman-adv/icmp_socket.c           |   6 +-
 net/batman-adv/main.c                  |  16 ++---
 net/batman-adv/network-coding.c        |  22 +++---
 net/batman-adv/packet.h                | 124 +++++++++++++++++++++++++--------
 net/batman-adv/routing.c               |  30 ++++----
 net/batman-adv/send.c                  |  10 +--
 net/batman-adv/soft-interface.c        |  18 +++--
 net/batman-adv/translation-table.c     |   6 +-
 11 files changed, 177 insertions(+), 105 deletions(-)
