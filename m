From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 0/4] net: dsa: Port mirroring support
Date: Sun, 29 Jan 2017 20:30:22 -0800
Message-ID: <20170130043026.28867-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        jiri@mellanox.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33482 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751853AbdA3Eaf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 23:30:35 -0500
Received: by mail-qk0-f193.google.com with SMTP id 11so17199128qkl.0
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 20:30:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds support for port mirroring in the two
Broadcom switch drivers. The major part of the functional are actually with
the plumbing between tc and the drivers.

David, this will most likely conflict a little bit with my other series:
 net: dsa: bcm_sf2: CFP support, so just let me know if that happens, and
I will provide a rebased version. Thanks!

Changes in v4:

- rebased against latest net-next/master after Vivien's changes

Changes in v3:

- removed multiline comments from added structures
- simplify error handling in dsa_slave_add_cls_matchall

Changes in v2:

- fixed filter removal logic to disable the ingress or egress mirroring
  when there are no longer ports being monitored in ingress or egress

- removed a stray list_head in dsa_port structure that is not used

Tested using the two iproute2 examples:

# ingress
      tc qdisc  add dev eth1 handle ffff: ingress
      tc filter add dev eth1 parent ffff:           \
               matchall skip_sw                      \
               action mirred egress mirror           \
               dev eth2
# egress
      tc qdisc add dev eth1 handle 1: root prio
      tc filter add dev eth1 parent 1:               \
               matchall skip_sw                       \
               action mirred egress mirror            \
               dev eth2


Florian Fainelli (4):
  net: dsa: Add plumbing for port mirroring
  net: dsa: b53: Add mirror capture register definitions
  net: dsa: b53: Add support for port mirroring
  net: dsa: bcm_sf2: Add support for port mirroring

 drivers/net/dsa/b53/b53_common.c |  67 +++++++++++++++++++
 drivers/net/dsa/b53/b53_priv.h   |   4 ++
 drivers/net/dsa/b53/b53_regs.h   |  32 ++++++++++
 drivers/net/dsa/bcm_sf2.c        |   2 +
 include/net/dsa.h                |  33 ++++++++++
 net/dsa/dsa_priv.h               |   3 +
 net/dsa/slave.c                  | 135 ++++++++++++++++++++++++++++++++++++++-
 7 files changed, 275 insertions(+), 1 deletion(-)

-- 
2.9.3
