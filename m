From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 0/3] export device physical port id to userspace
Date: Mon, 22 Jul 2013 15:05:14 +0200
Message-ID: <1374498317-6442-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Narendra_K@Dell.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com, or.gerlitz@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:50593 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754768Ab3GVNFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 09:05:23 -0400
Received: by mail-ee0-f54.google.com with SMTP id t10so3807707eei.41
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 06:05:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is based on patch by Narendra_K@Dell.com
Once device which can change phys port id during its lifetime adopts this,
NETDEV_CHANGEPHYSPORTID event will be added and driver will call
call_netdevice_notifiers(NETDEV_NETDEV_CHANGEPHYSPORTID, dev) to propagate
the change to userspace.

v1->v2: as suggested by Ben, handle -EOPNOTSUPP in rtnl code (wrapped up ndo call)
v2->v3: adjusted patch 1 commit message

Jiri Pirko (3):
  net: add ndo to get id of physical port of the device
  rtnl: export physical port id via RT netlink
  net: export physical port id via sysfs

 include/linux/netdevice.h    | 20 ++++++++++++++++++++
 include/uapi/linux/if_link.h |  1 +
 net/core/dev.c               | 18 ++++++++++++++++++
 net/core/net-sysfs.c         | 42 ++++++++++++++++++++++++++++++++++++++++++
 net/core/rtnetlink.c         | 25 ++++++++++++++++++++++++-
 5 files changed, 105 insertions(+), 1 deletion(-)

-- 
1.8.1.4
