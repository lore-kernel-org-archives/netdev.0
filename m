From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/4] Add support for offloading packet-sampling
Date: Mon, 23 Jan 2017 11:07:07 +0100
Message-ID: <1485166031-4773-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:32987 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750705AbdAWKHO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 05:07:14 -0500
Received: by mail-wj0-f195.google.com with SMTP id un2so1470742wjb.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 02:07:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Yotam says:

The first patch introduces the psample module, a netlink channel dedicated
to packet sampling implemented using generic netlink. This module provides
a generic way for kernel modules to sample packets, while not being tied
to any specific subsystem like NFLOG.

The second patch adds the sample tc action, which uses psample to randomly
sample packets that match a classifier. The user can configure the psample
group number, the sampling rate and the packet's truncation (to save
kernel-user traffic).

The last two patches add the support for offloading the matchall-sample
tc command in the mlxsw driver, for ingress qdiscs.

An example for psample usage can be found in the libpsample project at:
https://github.com/Mellanox/libpsample

---
v1->v2:
- Reword first patch's commit message
- Fix typo in comment in second patch
- Change order of tc_sample uapi enum to match convention
- Rename act_sample action callback tcf_sample -> tcf_sample_act

Yotam Gigi (4):
  net: Introduce psample, a new genetlink channel for packet sampling
  net/sched: Introduce sample tc action
  mlxsw: reg: add the Monitoring Packet Sampling Configuration Register
  mlxsw: spectrum: Add packet sample offloading support

 MAINTAINERS                                    |   7 +
 drivers/net/ethernet/mellanox/mlxsw/reg.h      |  41 ++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 111 +++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  10 +
 drivers/net/ethernet/mellanox/mlxsw/trap.h     |   1 +
 include/net/psample.h                          |  36 +++
 include/net/tc_act/tc_sample.h                 |  50 ++++
 include/uapi/linux/Kbuild                      |   1 +
 include/uapi/linux/psample.h                   |  35 +++
 include/uapi/linux/tc_act/Kbuild               |   1 +
 include/uapi/linux/tc_act/tc_sample.h          |  26 +++
 net/Kconfig                                    |   1 +
 net/Makefile                                   |   1 +
 net/psample/Kconfig                            |  15 ++
 net/psample/Makefile                           |   5 +
 net/psample/psample.c                          | 301 +++++++++++++++++++++++++
 net/sched/Kconfig                              |  12 +
 net/sched/Makefile                             |   1 +
 net/sched/act_sample.c                         | 274 ++++++++++++++++++++++
 19 files changed, 929 insertions(+)
 create mode 100644 include/net/psample.h
 create mode 100644 include/net/tc_act/tc_sample.h
 create mode 100644 include/uapi/linux/psample.h
 create mode 100644 include/uapi/linux/tc_act/tc_sample.h
 create mode 100644 net/psample/Kconfig
 create mode 100644 net/psample/Makefile
 create mode 100644 net/psample/psample.c
 create mode 100644 net/sched/act_sample.c

-- 
2.7.4
