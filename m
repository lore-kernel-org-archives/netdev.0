From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 21 Jul 2014 22:43:31 -0700 (PDT)
Message-ID: <20140721.224331.776951850963391346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Null termination fix in dns_resolver got the pointer dereferncing wr=
ong,
   fix from Ben Hutchings.

2) ip_options_compile() has a benign but real buffer overflow when pars=
ing
   options.  From Eric Dumazet.

3) Table updates can crash in netfilter's nftables if none of the state=
 flags
   indicate an actual change, from Pablo Neira Ayuso.

4) Fix race in nf_tables dumping, also from Pablo.

5) GRE-GRO support broke the forwarding path because the segmentation s=
tate
   was not fully initialized in these paths, from Jerry Chu.

6) sunvnet driver leaks objects and potentially crashes on module unloa=
d,
   from Sowmini Varadhan.

7) We can accidently generate the same handle for several u32 classifie=
r
   filters, fix from Cong Wang.

8) Several edge case bug fixes in fragment handling in xen-netback, fro=
m
   Zoltan Kiss.

Please pull, thanks!

The following changes since commit b6603fe574af289dbe9eb9fb4c540bca04f5=
a053:

  Merge tag 'for-linus-20140716' of git://git.infradead.org/linux-mtd (=
2014-07-16 10:11:42 -1000)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 850717ef00d8a224cf1aaffc9c636ea67e01cce2=
:

  Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/linux=
-merge (2014-07-21 20:19:09 -0700)

----------------------------------------------------------------

Amir Vadai (1):
      net/mlx4_en: cq->irq_desc wasn't set in legacy EQ's

Antonio Quartulli (1):
      batman-adv: fix TT VLAN inconsistency on VLAN re-add

Ben Hutchings (1):
      dns_resolver: Null-terminate the right string

Bj=F8rn Mork (2):
      net: qmi_wwan: add two Sierra Wireless/Netgear devices
      net: huawei_cdc_ncm: add "subclass 3" devices

Christoph Schulz (1):
      net: ppp: fix creating PPP pass and active filters

Cong Wang (1):
      net_sched: avoid generating same handle for u32 filters

Dan Carpenter (1):
      wan/x25_asy: integer overflow in x25_asy_change_mtu()

David S. Miller (3):
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'xen-netback'
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge

Eric Dumazet (2):
      netfilter: nf_tables: 64bit stats need some extra synchronization
      ipv4: fix buffer overflow in ip_options_compile()

Jerry Chu (1):
      net-gre-gro: Fix a bug that breaks the forwarding path

Michel D=E4nzer (1):
      r8169: Enable RX_MULTI_EN for RTL_GIGA_MAC_VER_40

Pablo Neira Ayuso (3):
      netfilter: nf_tables: skip transaction if no update flags in tabl=
es
      netfilter: nf_tables: safe RCU iteration on list when dumping
      netfilter: nf_tables: set NLM_F_DUMP_INTR if netlink dumping is s=
tale

Simon Wunderlich (1):
      batman-adv: drop QinQ claim frames in bridge loop avoidance

Sowmini Varadhan (1):
      sunvnet: clean up objects created in vnet_new() on vnet_exit()

Zoltan Kiss (4):
      xen-netback: Fix handling frag_list on grant op error path
      xen-netback: Fix releasing frag_list skbs in error path
      xen-netback: Fix releasing header slot on error path
      xen-netback: Fix pointer incrementation to avoid incorrect loggin=
g

 drivers/isdn/i4l/isdn_ppp.c                |  20 +++++++++---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c |   7 +++--
 drivers/net/ethernet/realtek/r8169.c       |   2 ++
 drivers/net/ethernet/sun/sunvnet.c         |  20 +++++++++++-
 drivers/net/ppp/ppp_generic.c              |  22 +++++++++----
 drivers/net/usb/huawei_cdc_ncm.c           |   3 ++
 drivers/net/usb/qmi_wwan.c                 |   2 ++
 drivers/net/wan/x25_asy.c                  |   6 +++-
 drivers/net/xen-netback/netback.c          |  86 +++++++++++++++++++++=
++++++++++++++++--------------
 include/net/netfilter/nf_tables.h          |   6 ++--
 include/net/netns/nftables.h               |   2 +-
 net/batman-adv/bridge_loop_avoidance.c     |  44 ++++++++++++++++++++-=
-----
 net/batman-adv/soft-interface.c            |  60 +++++++++++++++++++++=
++++++---------
 net/batman-adv/translation-table.c         |  26 ++++++++++++++++
 net/batman-adv/types.h                     |   2 ++
 net/core/dev.c                             |   2 ++
 net/dns_resolver/dns_query.c               |   2 +-
 net/ipv4/af_inet.c                         |   3 ++
 net/ipv4/gre_offload.c                     |   3 ++
 net/ipv4/ip_options.c                      |   4 +++
 net/ipv4/tcp_offload.c                     |   2 +-
 net/ipv6/tcpv6_offload.c                   |   2 +-
 net/netfilter/nf_tables_api.c              | 140 +++++++++++++++++++++=
++++++++++++++++++++++++++++++++------------------------------
 net/netfilter/nf_tables_core.c             |  10 +++---
 net/sched/cls_u32.c                        |  19 +++++++++---
 25 files changed, 367 insertions(+), 128 deletions(-)
