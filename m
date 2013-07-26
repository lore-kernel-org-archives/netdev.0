From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 0/4] export device physical port id to userspace
Date: Fri, 26 Jul 2013 14:09:52 +0200
Message-ID: <1374840596-5748-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Narendra_K@Dell.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com, or.gerlitz@gmail.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	vyasevic@redhat.com, amwang@redhat.com, johannes@sipsolutions.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:40285 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757003Ab3GZMKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 08:10:03 -0400
Received: by mail-ea0-f176.google.com with SMTP id q16so1511720ead.7
        for <netdev@vger.kernel.org>; Fri, 26 Jul 2013 05:10:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is based on patch by Narendra_K@Dell.com
Once device which can change phys port id during its lifetime adopts this,
NETDEV_CHANGEPHYSPORTID event will be added and driver will call
call_netdevice_notifiers(NETDEV_NETDEV_CHANGEPHYSPORTID, dev) to propagate
the change to userspace.

v1->v2: as suggested by Ben, handle -EOPNOTSUPP in rtnl code (wrapped up ndo call)
v2->v3: adjusted patch 1 commit message
v3->v4: used "%phN" for sysfs printf as suggested by DaveM
        added igb/igbvf implementation as requested by Or Gerlitz
v4->v5: used prandom_u32 to generate id in igb_probe
	removed duplicate code in ibgvf_probe
	pushed dev_err string into one line in igbvf_refresh_ppid

Jiri Pirko (4):
  net: add ndo to get id of physical port of the device
  rtnl: export physical port id via RT netlink
  net: export physical port id via sysfs
  igb/igbvf: implement ndo_get_phys_port_id

 drivers/net/ethernet/intel/igb/e1000_mbx.h |  1 +
 drivers/net/ethernet/intel/igb/igb.h       |  2 ++
 drivers/net/ethernet/intel/igb/igb_main.c  | 29 +++++++++++++++++++++-
 drivers/net/ethernet/intel/igbvf/igbvf.h   |  3 +++
 drivers/net/ethernet/intel/igbvf/mbx.h     |  1 +
 drivers/net/ethernet/intel/igbvf/netdev.c  | 40 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igbvf/vf.c      | 34 +++++++++++++++++++++++++
 drivers/net/ethernet/intel/igbvf/vf.h      |  1 +
 include/linux/netdevice.h                  | 20 +++++++++++++++
 include/uapi/linux/if_link.h               |  1 +
 net/core/dev.c                             | 18 ++++++++++++++
 net/core/net-sysfs.c                       | 22 ++++++++++++++++
 net/core/rtnetlink.c                       | 25 ++++++++++++++++++-
 13 files changed, 195 insertions(+), 2 deletions(-)

-- 
1.8.1.4
