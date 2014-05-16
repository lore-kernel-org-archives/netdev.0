From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 0/4] Fix lockdep issues with stacked devices
Date: Fri, 16 May 2014 11:36:40 -0400
Message-ID: <1400254604-23910-1-git-send-email-vyasevic@redhat.com>
Cc: dingtianhong@huawei.com, kaber@trash.net, vfalico@gmail.com,
	jiri@resnulli.us, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30942 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932283AbaEPPg5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 11:36:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent commit dc8eaaa006350d24030502a4521542e74b5cb39f
    vlan: Fix lockdep warning when vlan dev handle notification

attempted to solve lockdep issues with vlans where multiple
vlans were stacked.  However, the code does not work correctly
when the vlan stack is interspersed with other devices in between
the vlans.  Additionally, similar lockdep issues show up with other
devices.

This series provides a generic way to solve these issue for any
devices that can be stacked.  It also addresses the concern for
vlan and macvlan devices.  I am not sure whether it makes sense
to do so for other types like team, vxlan, and bond.

Thanks
-vlad

Vlad Yasevich (4):
  net: Find the nesting level of a given device by type.
  net: Allow for more then a single subclass for netif_addr_lock
  vlan: Fix lockdep warning with stacked vlan devices.
  macvlan: Fix lockdep warnings with stacked macvlan devices

 drivers/net/macvlan.c      | 12 +++++++++--
 include/linux/if_macvlan.h |  1 +
 include/linux/if_vlan.h    |  1 +
 include/linux/netdevice.h  | 18 +++++++++++++++-
 net/8021q/vlan.c           |  1 +
 net/8021q/vlan_dev.c       | 52 ++++++++--------------------------------------
 net/core/dev.c             | 49 ++++++++++++++++++++++++++++++++++++++++++-
 7 files changed, 87 insertions(+), 47 deletions(-)

-- 
1.9.0
