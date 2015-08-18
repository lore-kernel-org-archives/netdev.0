From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 00/21] net: Convert drivers to IFF_NO_QUEUE and cleanup afterwards
Date: Tue, 18 Aug 2015 10:30:28 +0200
Message-ID: <1439886649-24166-1-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:58953 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751504AbbHRIav (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series converts in-tree users away from the old and deprecated
'tx_queue_len = 0' idiom, adds a warning to notify out-of-tree driver
maintainers that there is need for action on their behalf and finally drops any
workarounds in scheduling algorithm implementations.

Phil Sutter (21):
  net: veth: enable noqueue operation by default
  net: dummy: convert to using IFF_NO_QUEUE
  net: geneve: convert to using IFF_NO_QUEUE
  net: loopback: convert to using IFF_NO_QUEUE
  net: nlmon: convert to using IFF_NO_QUEUE
  net: team: convert to using IFF_NO_QUEUE
  net: vxlan: convert to using IFF_NO_QUEUE
  net: 8021q: convert to using IFF_NO_QUEUE
  net: bridge: convert to using IFF_NO_QUEUE
  net: 6lowpan: convert to using IFF_NO_QUEUE
  net: bonding: convert to using IFF_NO_QUEUE
  net: ipvlan: convert to using IFF_NO_QUEUE
  net: dsa: convert to using IFF_NO_QUEUE
  net: hostap: convert to using IFF_NO_QUEUE
  net: mac80211_hwsim: convert to using IFF_NO_QUEUE
  net: batman-adv: convert to using IFF_NO_QUEUE
  net: hsr: convert to using IFF_NO_QUEUE
  net: caif: convert to using IFF_NO_QUEUE
  staging: wilc1000: convert to using IFF_NO_QUEUE
  net: warn if drivers set tx_queue_len = 0
  net: sched: drop all special handling of tx_queue_len == 0

 drivers/net/bonding/bond_main.c           | 3 +--
 drivers/net/caif/caif_hsi.c               | 2 +-
 drivers/net/caif/caif_serial.c            | 2 +-
 drivers/net/caif/caif_spi.c               | 2 +-
 drivers/net/dummy.c                       | 3 +--
 drivers/net/geneve.c                      | 3 +--
 drivers/net/ipvlan/ipvlan_main.c          | 3 +--
 drivers/net/loopback.c                    | 3 +--
 drivers/net/nlmon.c                       | 2 +-
 drivers/net/team/team.c                   | 2 +-
 drivers/net/veth.c                        | 1 +
 drivers/net/vxlan.c                       | 3 +--
 drivers/net/wan/hdlc_fr.c                 | 2 +-
 drivers/net/wireless/hostap/hostap_main.c | 4 ++--
 drivers/net/wireless/mac80211_hwsim.c     | 2 +-
 drivers/staging/wilc1000/linux_mon.c      | 2 +-
 net/8021q/vlan_dev.c                      | 3 +--
 net/batman-adv/soft-interface.c           | 2 +-
 net/bridge/br_device.c                    | 3 +--
 net/caif/caif_dev.c                       | 2 +-
 net/core/dev.c                            | 3 +++
 net/dsa/slave.c                           | 2 +-
 net/hsr/hsr_device.c                      | 2 +-
 net/ieee802154/6lowpan/core.c             | 2 +-
 net/sched/sch_fifo.c                      | 2 +-
 net/sched/sch_gred.c                      | 8 +++-----
 net/sched/sch_htb.c                       | 6 ++----
 net/sched/sch_plug.c                      | 8 ++------
 net/sched/sch_sfb.c                       | 2 +-
 29 files changed, 36 insertions(+), 48 deletions(-)

-- 
2.1.2
