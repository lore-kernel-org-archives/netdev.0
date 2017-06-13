From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 0/4] net: dsa: Multi-CPU ground work (v3)
Date: Tue, 13 Jun 2017 12:17:21 -0700
Message-ID: <20170613191725.26625-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, john@phrozen.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33262 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753448AbdFMTRf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 15:17:35 -0400
Received: by mail-wr0-f194.google.com with SMTP id v104so32984887wrb.0
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 12:17:34 -0700 (PDT)
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

Changes in v3:

- removed the last patch since it causes problems with bcm_sf2/b53 in a
  dual-CPU case (root cause known, proper fix underway)

- removed dsa_ds_get_cpu_dp()

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
