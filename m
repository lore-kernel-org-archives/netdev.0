From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/13] nftables updates for net-next
Date: Mon,  6 Jan 2014 14:46:29 +0100
Message-ID: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains nftables updates for your net-next tree,
they are:

* Add set operation to the meta expression by means of the select_ops()
  infrastructure, this allows us to set the packet mark among other things.
  From Arturo Borrero Gonzalez.

* Fix wrong format in sscanf in nf_tables_set_alloc_name(), from Daniel
  Borkmann.

* Add new queue expression to nf_tables. These comes with two previous patches
  to prepare this new feature, one to add mask in nf_tables_core to
  evaluate the queue verdict appropriately and another to refactor common
  code with xt_NFQUEUE, from Eric Leblond.

* Do not hide nftables from Kconfig if nfnetlink is not enabled, also from
  Eric Leblond.

* Add the reject expression to nf_tables, this adds the missing TCP RST
  support. It comes with an initial patch to refactor common code with
  xt_NFQUEUE, again from Eric Leblond.

* Remove an unused variable assignment in nf_tables_dump_set(), from Michal
  Nazarewicz.

* Remove the nft_meta_target code, now that Arturo added the set operation
  to the meta expression, from me.

* Add help information for nf_tables to Kconfig, also from me.

* Allow to dump all sets by specifying NFPROTO_UNSPEC, similar feature is
  available to other nf_tables objects, requested by Arturo, from me.

* Expose the table usage counter, so we can know how many chains are using
  this table without dumping the list of chains, from Tomasz Bursztyka.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nftables.git master

Thanks!

----------------------------------------------------------------

The following changes since commit cfce0a2b61d0658d40bc2af2dca28a817804e17a:

  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next (2013-11-05 02:34:57 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nftables.git master

for you to fetch changes up to c9c8e485978a308c8a359140da187d55120f8fee:

  netfilter: nf_tables: dump sets in all existing families (2014-01-04 00:23:11 +0100)

----------------------------------------------------------------
Arturo Borrero Gonzalez (1):
      netfilter: nf_tables: nft_meta module get/set ops

Daniel Borkmann (1):
      netfilter: nf_tables: fix type in parsing in nf_tables_set_alloc_name()

Eric Leblond (6):
      netfilter: nf_tables: fix issue with verdict support
      netfilter: xt_NFQUEUE: separate reusable code
      netfilter: nft: add queue module
      netfilter: select NFNETLINK when enabling NF_TABLES
      netfilter: REJECT: separate reusable code
      netfilter: nft_reject: support for IPv6 and TCP reset

Michal Nazarewicz (1):
      netfilter: nf_tables: remove unused variable in nf_tables_dump_set()

Pablo Neira Ayuso (3):
      netfilter: nf_tables: remove nft_meta_target
      netfilter: add help information to new nf_tables Kconfig options
      netfilter: nf_tables: dump sets in all existing families

Tomasz Bursztyka (1):
      netfilter: nf_tables: Expose the table usage counter via netlink

 include/net/netfilter/ipv4/nf_reject.h             |  128 ++++++++++++++
 include/net/netfilter/ipv6/nf_reject.h             |  171 +++++++++++++++++++
 include/net/netfilter/nf_queue.h                   |   62 +++++++
 include/uapi/linux/netfilter/nf_tables.h           |   24 +++
 net/ipv4/netfilter/Kconfig                         |   18 +-
 net/ipv4/netfilter/Makefile                        |    1 -
 net/ipv4/netfilter/ipt_REJECT.c                    |  140 ++-------------
 net/ipv6/netfilter/Kconfig                         |   12 ++
 net/ipv6/netfilter/ip6t_REJECT.c                   |  179 +-------------------
 net/netfilter/Kconfig                              |   59 ++++++-
 net/netfilter/Makefile                             |    3 +-
 net/netfilter/nf_tables_api.c                      |  104 ++++++++++--
 net/netfilter/nf_tables_core.c                     |    5 +-
 net/netfilter/nft_meta.c                           |  146 +++++++++++++---
 net/netfilter/nft_meta_target.c                    |  117 -------------
 net/netfilter/nft_queue.c                          |  134 +++++++++++++++
 .../nft_reject_ipv4.c => netfilter/nft_reject.c}   |   25 ++-
 net/netfilter/xt_NFQUEUE.c                         |   80 ++-------
 18 files changed, 873 insertions(+), 535 deletions(-)
 create mode 100644 include/net/netfilter/ipv4/nf_reject.h
 create mode 100644 include/net/netfilter/ipv6/nf_reject.h
 delete mode 100644 net/netfilter/nft_meta_target.c
 create mode 100644 net/netfilter/nft_queue.c
 rename net/{ipv4/netfilter/nft_reject_ipv4.c => netfilter/nft_reject.c} (77%)
