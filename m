From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 00/19] mlxsw: Introduce TC Flower offload using TCAM
Date: Fri,  3 Feb 2017 10:28:50 +0100
Message-ID: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com, tom@herbertland.com,
        f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36316 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751878AbdBCJ3M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 04:29:12 -0500
Received: by mail-wm0-f65.google.com with SMTP id r18so3089438wmd.3
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 01:29:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset introduces support for offloading TC cls_flower and actions
to Spectrum TCAM-base policy engine.

The patchset contains patches to allow work with flexible keys and actions
which are used in Spectrum TCAM.

It also contains in-driver infrastructure for offloading TC rules to TCAM HW.
The TCAM management code is simple and limited for now. It is going to be
extended as a follow-up work.

The last patch uses the previously introduced infra to allow to implement
cls_flower offloading. Initially, only limited set of match-keys and only
a drop and forward actions are supported.

As a dependency, this patchset introduces parman - priority array
area manager - as a library.

---
v1->v2:
- patch11:
  - use __set_bit and __test_and_clear_bit as suggested by DaveM
- patch16:
  - Added documentation to the API functions as suggested by Tom Herbert
- patch17:
  - use __set_bit and __clear_bit as suggested by DaveM

Jiri Pirko (19):
  mlxsw: item: Add 8bit item helpers
  mlxsw: item: Add helpers for getting pointer into payload for char
    buffer item
  mlxsw: reg: Add Policy-Engine ACL Register
  mlxsw: reg: Add Policy-Engine ACL Group Table register
  mlxsw: reg: Add Policy-Engine TCAM Allocation Register
  mlxsw: reg: Add Policy-Engine TCAM Entry Register Version 2
  mlxsw: reg: Add Policy-Engine Port Binding Table
  mlxsw: reg: Add Policy-Engine Rules Copy Register
  mlxsw: reg: Add Policy-Engine Policy Based Switching Register
  mlxsw: reg: Add Policy-Engine Extended Flexible Action Register
  mlxsw: core: Introduce flexible keys support
  mlxsw: core: Introduce flexible actions support
  mlxsw: spectrum: Introduce basic set of flexible key blocks
  mlxsw: resources: Add ACL related resources
  list: introduce list_for_each_entry_from_reverse helper
  lib: Introduce priority array area manager
  mlxsw: spectrum: Introduce ACL core with simple TCAM implementation
  sched: cls_flower: expose priority to offloading netdevice
  mlxsw: spectrum: Implement TC flower offload

 MAINTAINERS                                        |    8 +
 drivers/net/ethernet/mellanox/mlxsw/Kconfig        |    1 +
 drivers/net/ethernet/mellanox/mlxsw/Makefile       |    6 +-
 .../mellanox/mlxsw/core_acl_flex_actions.c         |  685 +++++++++++++
 .../mellanox/mlxsw/core_acl_flex_actions.h         |   66 ++
 .../ethernet/mellanox/mlxsw/core_acl_flex_keys.c   |  475 +++++++++
 .../ethernet/mellanox/mlxsw/core_acl_flex_keys.h   |  238 +++++
 drivers/net/ethernet/mellanox/mlxsw/item.h         |   98 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  511 ++++++++-
 drivers/net/ethernet/mellanox/mlxsw/resources.h    |   20 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   32 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  106 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c |  572 +++++++++++
 .../mellanox/mlxsw/spectrum_acl_flex_keys.h        |  109 ++
 .../ethernet/mellanox/mlxsw/spectrum_acl_tcam.c    | 1084 ++++++++++++++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  |  309 ++++++
 include/linux/list.h                               |   13 +
 include/linux/parman.h                             |   76 ++
 include/net/pkt_cls.h                              |    1 +
 lib/Kconfig                                        |    3 +
 lib/Kconfig.debug                                  |   10 +
 lib/Makefile                                       |    3 +
 lib/parman.c                                       |  376 +++++++
 lib/test_parman.c                                  |  395 +++++++
 net/sched/cls_flower.c                             |    3 +
 25 files changed, 5184 insertions(+), 16 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
 create mode 100644 include/linux/parman.h
 create mode 100644 lib/parman.c
 create mode 100644 lib/test_parman.c

-- 
2.7.4
