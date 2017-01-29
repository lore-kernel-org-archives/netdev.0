From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 0/4] net: dsa: Port mirroring support
Date: Sun, 29 Jan 2017 11:29:06 -0800
Message-ID: <20170129192910.6069-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        jiri@mellanox.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f195.google.com ([74.125.82.195]:33370 "EHLO
        mail-ot0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751493AbdA2Tfr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 14:35:47 -0500
Received: by mail-ot0-f195.google.com with SMTP id f9so36359059otd.0
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 11:35:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds support for port mirroring in the two
Broadcom switch drivers. The major part of the functional are actually with
the plumbing between tc and the drivers.

David, this will most likely conflict a little bit with my other series:
 net: dsa: bcm_sf2: CFP support, so just let me know if that happens, and
I will provide a rebased version. Thanks!

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
