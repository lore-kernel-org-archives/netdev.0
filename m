From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/17] Netfilter updates for net-next
Date: Fri,  8 Jan 2016 15:02:00 +0100
Message-ID: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter updates for net-next, they ar=
e:

1) Release nf_tables objects on netns destructions via
   nft_release_afinfo().

2) Destroy basechain and rules on netdevice removal in the new netdev
   family.

3) Get rid of defensive check against removal of inactive objects in
   nf_tables.

4) Pass down netns pointer to our existing nfnetlink callbacks, as well
   as commit() and abort() nfnetlink callbacks.

5) Allow to invert limit expression in nf_tables, so we can throttle
   overlimit traffic.

6) Add packet duplication for the netdev family.

7) Add forward expression for the netdev family.

8) Define pr_fmt() in conntrack helpers.

9) Don't leave nfqueue configuration on inconsistent state in case of
   errors, from Ken-ichirou MATSUZAWA, follow up patches are also from
   him.

10) Skip queue option handling after unbind.

11) Return error on unknown both in nfqueue and nflog command.

12) Autoload ctnetlink when NFQA_CFG_F_CONNTRACK is set.

13) Add new NFTA_SET_USERDATA attribute to store user data in sets,
    from Carlos Falgueras.

14) Add support for 64 bit byteordering changes nf_tables, from Florian
    Westphal.

15) Add conntrack byte/packet counter matching support to nf_tables,
    also from Florian.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 26a4d063b1357e3ad81b776eb89d4d82f101=
da2c:

  Merge branch 'bnxt_en-next' (2015-12-28 00:57:29 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to 48f66c905a976bf0ff092fc24f08d9addd82a245=
:

  netfilter: nft_ct: add byte/packet counter support (2016-01-08 14:44:=
09 +0100)

----------------------------------------------------------------
Carlos Falgueras Garc=C3=ADa (1):
      netfilter: nf_tables: Add new attributes into nft_set to store us=
er data.

=46lorian Westphal (2):
      netfilter: nft_byteorder: provide 64bit le/be conversion
      netfilter: nft_ct: add byte/packet counter support

Ken-ichirou MATSUZAWA (5):
      netfilter: nfnetlink_queue: validate dependencies to avoid breaki=
ng atomicity
      netfilter: nfnetlink_queue: don't handle options after unbind
      netfilter: nfnetlink_queue: just returns error for unknown comman=
d
      netfilter: nfnetlink_queue: autoload nf_conntrack_netlink module =
NFQA_CFG_F_CONNTRACK config flag
      netfilter: nfnetlink_log: just returns error for unknown command

Pablo Neira Ayuso (9):
      netfilter: nf_tables: release objects on netns destruction
      netfilter: nf_tables: destroy basechain and rules on netdevice re=
moval
      netfilter: nf_tables: remove check against removal of inactive ob=
jects
      netfilter: nfnetlink: pass down netns pointer to call() and call_=
rcu()
      netfilter: nfnetlink: pass down netns pointer to commit() and abo=
rt() callbacks
      netfilter: nft_limit: allow to invert matching criteria
      netfilter: nf_tables: add packet duplication to the netdev family
      netfilter: nf_tables: add forward expression to the netdev family
      netfilter: nf_ct_helper: define pr_fmt()

 include/linux/netfilter/nfnetlink.h      |  12 +--
 include/net/netfilter/nf_dup_netdev.h    |   6 ++
 include/net/netfilter/nf_tables.h        |  11 ++-
 include/uapi/linux/netfilter/nf_tables.h |  22 +++++
 net/bridge/netfilter/nf_tables_bridge.c  |   2 +-
 net/ipv4/netfilter/nf_tables_arp.c       |   2 +-
 net/ipv4/netfilter/nf_tables_ipv4.c      |   2 +-
 net/ipv6/netfilter/nf_tables_ipv6.c      |   2 +-
 net/netfilter/Kconfig                    |  22 +++++
 net/netfilter/Makefile                   |   7 ++
 net/netfilter/ipset/ip_set_core.c        | 108 +++++++++-----------
 net/netfilter/nf_conntrack_ftp.c         |  17 ++--
 net/netfilter/nf_conntrack_irc.c         |   7 +-
 net/netfilter/nf_conntrack_netlink.c     |  96 ++++++++----------
 net/netfilter/nf_conntrack_sane.c        |  19 ++--
 net/netfilter/nf_conntrack_sip.c         |   5 +-
 net/netfilter/nf_conntrack_tftp.c        |   7 +-
 net/netfilter/nf_dup_netdev.c            |  40 ++++++++
 net/netfilter/nf_tables_api.c            | 164 +++++++++++++++++++++--=
--------
 net/netfilter/nf_tables_inet.c           |   2 +-
 net/netfilter/nf_tables_netdev.c         |  47 ++++-----
 net/netfilter/nfnetlink.c                |  12 +--
 net/netfilter/nfnetlink_acct.c           |  21 ++--
 net/netfilter/nfnetlink_cthelper.c       |  18 ++--
 net/netfilter/nfnetlink_cttimeout.c      |  42 ++++----
 net/netfilter/nfnetlink_log.c            |  17 ++--
 net/netfilter/nfnetlink_queue.c          | 123 +++++++++++------------
 net/netfilter/nft_byteorder.c            |  23 +++++
 net/netfilter/nft_compat.c               |   6 +-
 net/netfilter/nft_ct.c                   |  38 +++++++
 net/netfilter/nft_dup_netdev.c           |  97 ++++++++++++++++++
 net/netfilter/nft_fwd_netdev.c           |  98 ++++++++++++++++++
 net/netfilter/nft_limit.c                |  16 ++-
 net/netfilter/xt_osf.c                   |   7 +-
 34 files changed, 749 insertions(+), 369 deletions(-)
 create mode 100644 include/net/netfilter/nf_dup_netdev.h
 create mode 100644 net/netfilter/nf_dup_netdev.c
 create mode 100644 net/netfilter/nft_dup_netdev.c
 create mode 100644 net/netfilter/nft_fwd_netdev.c
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
