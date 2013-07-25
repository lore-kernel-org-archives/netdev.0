From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 0/4] export device physical port id to userspace
Date: Thu, 25 Jul 2013 15:03:01 +0200
Message-ID: <1374757385-10875-1-git-send-email-jiri@resnulli.us>
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
Received: from mail-ee0-f54.google.com ([74.125.83.54]:63132 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755595Ab3GYNDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 09:03:12 -0400
Received: by mail-ee0-f54.google.com with SMTP id t10so914913eei.27
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 06:03:11 -0700 (PDT)
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

Jiri Pirko (4):
  net: add ndo to get id of physical port of the device
  rtnl: export physical port id via RT netlink
  net: export physical port id via sysfs
  igb/igbvf: implement ndo_get_phys_port_id

 drivers/net/ethernet/intel/igb/e1000_mbx.h |  1 +
 drivers/net/ethernet/intel/igb/igb.h       |  2 ++
 drivers/net/ethernet/intel/igb/igb_main.c  | 43 +++++++++++++++++++++++++++-
 drivers/net/ethernet/intel/igbvf/igbvf.h   |  3 ++
 drivers/net/ethernet/intel/igbvf/mbx.h     |  1 +
 drivers/net/ethernet/intel/igbvf/netdev.c  | 45 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igbvf/vf.c      | 34 ++++++++++++++++++++++
 drivers/net/ethernet/intel/igbvf/vf.h      |  1 +
 include/linux/netdevice.h                  | 20 +++++++++++++
 include/uapi/linux/if_link.h               |  1 +
 net/core/dev.c                             | 18 ++++++++++++
 net/core/net-sysfs.c                       | 22 +++++++++++++++
 net/core/rtnetlink.c                       | 25 ++++++++++++++++-
 13 files changed, 214 insertions(+), 2 deletions(-)

-- 
1.8.1.4
