From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 0/4] nsh: headers, GSO
Date: Mon, 28 Aug 2017 21:43:20 +0200
Message-ID: <cover.1503948295.git.jbenc@redhat.com>
Cc: Yi Yang <yi.y.yang@intel.com>, Eric Garver <e@erig.me>,
        Jan Scheurich <jan.scheurich@ericsson.com>,
        Ben Pfaff <blp@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35264 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751192AbdH1Tnj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 15:43:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds header structs and helpers for NSH together with GSO support.

Note there is no code in this patchset that actually manipulates the NSH
headers. That was sent to netdev by Yi Yang ("[PATCH net-next v6 0/3]
openvswitch: add NSH support"). The aim of this series is to lay the
groundwork and ease the implementation for him.

In addition to openvswitch, the NSH support should be added to tc (flower to
match, act_nsh to push/pop NSH headers). That will come later. There's
currently no plan to support NSH by other means than those two.

The patch 3 in this patchset was written by Yi Yang, I took it from the
aforementioned series and slightly modified it - see the note in the patch.

Jiri Benc (3):
  ether: add NSH ethertype
  vxlan: factor out VXLAN-GPE next protocol
  nsh: add GSO support

Yi Yang (1):
  net: add NSH header structures and helpers

 drivers/net/vxlan.c           |  32 +----
 include/net/nsh.h             | 307 ++++++++++++++++++++++++++++++++++++++++++
 include/net/tun_proto.h       |  49 +++++++
 include/net/vxlan.h           |   6 -
 include/uapi/linux/if_ether.h |   1 +
 net/Kconfig                   |   1 +
 net/Makefile                  |   1 +
 net/nsh/Kconfig               |   9 ++
 net/nsh/Makefile              |   1 +
 net/nsh/nsh.c                 |  91 +++++++++++++
 10 files changed, 467 insertions(+), 31 deletions(-)
 create mode 100644 include/net/nsh.h
 create mode 100644 include/net/tun_proto.h
 create mode 100644 net/nsh/Kconfig
 create mode 100644 net/nsh/Makefile
 create mode 100644 net/nsh/nsh.c

-- 
1.8.3.1
