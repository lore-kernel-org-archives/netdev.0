From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/5] net: dsa: Multi-CPU ground work
Date: Tue,  6 Jun 2017 10:01:57 -0700
Message-ID: <20170606170202.21491-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        john@phrozen.org, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:36161 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751600AbdFFRCG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 13:02:06 -0400
Received: by mail-qt0-f195.google.com with SMTP id s33so17364884qtg.3
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 10:02:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series prepares the ground for adding mutliple CPU port support to
DSA, and starts by removing redundant pieces of information such as
master_netdev which is cpu_dp->ethernet. Finally drivers are moved away from
directly accessing ds->dst->cpu_dp and use appropriate helper functions.

Note that if you have Device Tree blobs/platform configurations that are
currently listing multiple CPU ports, the proposed behavior in
dsa_ds_get_cpu_dp() will be to return the last bit set in ds->cpu_port_mask.

Future plans include:
- making dst->cpu_dp a flexible data structure (array, list, you name it)
- having the ability for drivers to return a default/preferred CPU port (if
  necessary)

Florian Fainelli (5):
  net: dsa: Remove master_netdev and use dst->cpu_dp->netdev
  net: dsa: Relocate master ethtool operations
  net: dsa: Associate slave network device with CPU port
  net: dsa: Introduce dsa_dst_get_cpu_dp()
  net: dsa: Stop accessing ds->dst->cpu_dp in drivers

 drivers/net/dsa/b53/b53_common.c |  4 +--
 drivers/net/dsa/bcm_sf2.c        | 10 +++++---
 drivers/net/dsa/mt7530.c         |  6 +++--
 drivers/net/dsa/mv88e6060.c      |  3 ++-
 drivers/net/dsa/qca8k.c          |  2 +-
 include/net/dsa.h                | 29 +++++++++------------
 net/dsa/dsa.c                    | 19 ++++----------
 net/dsa/dsa2.c                   | 18 ++++++--------
 net/dsa/dsa_priv.h               | 10 ++++++++
 net/dsa/legacy.c                 | 22 +++++++++-------
 net/dsa/slave.c                  | 54 +++++++++++++++++++++-------------------
 net/dsa/tag_brcm.c               |  5 ++--
 net/dsa/tag_ksz.c                |  5 ++--
 net/dsa/tag_qca.c                |  3 ++-
 net/dsa/tag_trailer.c            |  5 ++--
 15 files changed, 98 insertions(+), 97 deletions(-)

-- 
2.9.3
