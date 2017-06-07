From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/5] net: dsa: Multi-CPU ground work (v2)
Date: Tue,  6 Jun 2017 17:03:12 -0700
Message-ID: <20170607000317.14729-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        john@phrozen.org, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35168 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750766AbdFGAD1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 20:03:27 -0400
Received: by mail-wm0-f67.google.com with SMTP id g15so130703wmc.2
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 17:03:26 -0700 (PDT)
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

Changes in v2:

- added Reviewed-by tags
- assign port->cpu_dp earlier before ops->setup() has run

Florian Fainelli (5):
  net: dsa: Remove master_netdev and use dst->cpu_dp->netdev
  net: dsa: Relocate master ethtool operations
  net: dsa: Associate slave network device with CPU port
  net: dsa: Introduce dsa_dst_get_cpu_dp()
  net: dsa: Stop accessing ds->dst->cpu_dp in drivers

 drivers/net/dsa/b53/b53_common.c |  4 +--
 drivers/net/dsa/bcm_sf2.c        | 10 +++++---
 drivers/net/dsa/mt7530.c         |  6 +++--
 drivers/net/dsa/mv88e6060.c      |  2 +-
 drivers/net/dsa/qca8k.c          |  2 +-
 include/net/dsa.h                | 29 +++++++++-------------
 net/dsa/dsa.c                    | 19 ++++----------
 net/dsa/dsa2.c                   | 27 ++++++++++++--------
 net/dsa/dsa_priv.h               | 10 ++++++++
 net/dsa/legacy.c                 | 23 ++++++++++-------
 net/dsa/slave.c                  | 53 ++++++++++++++++++++--------------------
 net/dsa/tag_brcm.c               |  5 ++--
 net/dsa/tag_ksz.c                |  5 ++--
 net/dsa/tag_qca.c                |  3 ++-
 net/dsa/tag_trailer.c            |  5 ++--
 15 files changed, 107 insertions(+), 96 deletions(-)

-- 
2.9.3
