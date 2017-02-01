From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH v2 net-next 0/3] Extract IFE logic to module
Date: Wed,  1 Feb 2017 15:30:00 +0200
Message-ID: <1485955803-65065-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: jhs@mojatatu.com, davem@davemloft.net, netdev@vger.kernel.org,
        mrv@mojatatu.com, eladr@mellanox.com, jiri@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41036 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750858AbdBAN1p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 08:27:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extract ife logic from the tc_ife action into an independent module, and
make the tc_ife action use it. This way, the ife encapsulation can be used
by other modules other than tc_ife action.

v1->v2:
Fix duplicate symbol error by introducing a new patch that makes the
original symbol static.

The symbol ife_tlv_meta_extract is exported in act_ife, though not being
used by any other module. As the symbol is being moved to the new ife
module, introducing the new module creates duplicate symbol. To fix it,
add a new patch (1/3) that makes the ife_tlv_meta_extract symbol static in
act_ife, thus the symbol does not collide.

Yotam Gigi (3):
  net/sched: act_ife: Unexport ife_tlv_meta_encode
  net: Introduce ife encapsulation module
  net/sched: act_ife: Change to use ife module

 MAINTAINERS                        |   7 ++
 include/net/ife.h                  |  51 +++++++++++++
 include/net/tc_act/tc_ife.h        |   3 -
 include/uapi/linux/Kbuild          |   1 +
 include/uapi/linux/ife.h           |  18 +++++
 include/uapi/linux/tc_act/tc_ife.h |  10 +--
 net/Kconfig                        |   1 +
 net/Makefile                       |   1 +
 net/ife/Kconfig                    |  16 +++++
 net/ife/Makefile                   |   5 ++
 net/ife/ife.c                      | 142 +++++++++++++++++++++++++++++++++++++
 net/sched/Kconfig                  |   1 +
 net/sched/act_ife.c                | 110 +++++++++-------------------
 13 files changed, 276 insertions(+), 90 deletions(-)
 create mode 100644 include/net/ife.h
 create mode 100644 include/uapi/linux/ife.h
 create mode 100644 net/ife/Kconfig
 create mode 100644 net/ife/Makefile
 create mode 100644 net/ife/ife.c

-- 
2.4.11
