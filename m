From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 0/6] Add support for offloading packet-sampling
Date: Wed, 12 Oct 2016 14:41:03 +0200
Message-ID: <1476276069-5315-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34116 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754038AbcJLMl0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 08:41:26 -0400
Received: by mail-lf0-f68.google.com with SMTP id x23so1213487lfi.1
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 05:41:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add the sample tc action, which allows to sample packet matching
a classifier. The sample action peeks randomly packets, duplicates them,
truncates them and adds informative metadata on the packet, for example,
the input interface and the original packet length. The sampled packets
are marked to allow matching them and redirecting them to a specific
collector device.

The sampled packets metadata is packed using ife encapsulation. To do
that, this patch-set extracts ife logics from the tc_ife action into an
independent ife module, and uses that functionality to pack the metadata.
To include all the needed metadata, this patch-set introduces some new
IFE_META tlv types.

In addition, Add the support for offloading the matchall-sample tc command
in the Mellanox mlxsw driver, for ingress qdiscs.

Yotam Gigi (6):
  Introduce ife encapsulation module
  act_ife: Change to use ife module
  ife: Introduce new metadata tlv types
  Introduce sample tc action
  mlxsw: reg: add the Monitoring Packet Sampling Configuration Register
  mlxsw: packet sample: Add packet sample offloading support

 MAINTAINERS                                    |   7 +
 drivers/net/ethernet/mellanox/mlxsw/reg.h      |  43 ++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 116 +++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  11 +
 drivers/net/ethernet/mellanox/mlxsw/trap.h     |   1 +
 include/net/ife.h                              |  19 ++
 include/net/tc_act/tc_ife.h                    |   3 -
 include/net/tc_act/tc_sample.h                 |  88 ++++++++
 include/uapi/linux/Kbuild                      |   1 +
 include/uapi/linux/ife.h                       |  19 ++
 include/uapi/linux/tc_act/Kbuild               |   1 +
 include/uapi/linux/tc_act/tc_ife.h             |  10 +-
 include/uapi/linux/tc_act/tc_sample.h          |  31 +++
 net/Kconfig                                    |   1 +
 net/Makefile                                   |   1 +
 net/ife/Kconfig                                |  16 ++
 net/ife/Makefile                               |   5 +
 net/ife/ife.c                                  | 147 ++++++++++++
 net/sched/Kconfig                              |  14 ++
 net/sched/Makefile                             |   1 +
 net/sched/act_ife.c                            | 109 +++------
 net/sched/act_sample.c                         | 300 +++++++++++++++++++++++++
 22 files changed, 849 insertions(+), 95 deletions(-)
 create mode 100644 include/net/ife.h
 create mode 100644 include/net/tc_act/tc_sample.h
 create mode 100644 include/uapi/linux/ife.h
 create mode 100644 include/uapi/linux/tc_act/tc_sample.h
 create mode 100644 net/ife/Kconfig
 create mode 100644 net/ife/Makefile
 create mode 100644 net/ife/ife.c
 create mode 100644 net/sched/act_sample.c

-- 
2.5.5
