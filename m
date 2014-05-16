From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v3 0/4]  Fix lockdep issues with stacked devices
Date: Fri, 16 May 2014 17:04:52 -0400
Message-ID: <1400274296-14765-1-git-send-email-vyasevic@redhat.com>
Cc: dingtianhong@huawei.com, kaber@trash.net, vfalico@gmail.com,
	jiri@resnulli.us, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35218 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752143AbaEPV5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 17:57:16 -0400
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

Since v2:
  - Remove rcu variants from patch1, since that function is called
    only under rtnl.
  - Fix whitespace problems reported by checkpatch

Since v1:
  - Fixed up a goofed-up rebase.
    * is_vlan_dev() should be bool and that change belongs in patch3.
    * patch4 should not have any vlan changes in it.

Vlad Yasevich (4):
  net: Find the nesting level of a given device by type.
  net: Allow for more then a single subclass for netif_addr_lock
  vlan: Fix lockdep warning with stacked vlan devices.
  macvlan: Fix lockdep warnings with stacked macvlan devices

 drivers/net/macvlan.c      | 12 +++++++++--
 include/linux/if_macvlan.h |  1 +
 include/linux/if_vlan.h    |  3 ++-
 include/linux/netdevice.h  | 18 +++++++++++++++-
 net/8021q/vlan.c           |  1 +
 net/8021q/vlan_dev.c       | 52 ++++++++--------------------------------------
 net/core/dev.c             | 49 ++++++++++++++++++++++++++++++++++++++++++-
 7 files changed, 88 insertions(+), 48 deletions(-)

-- 
1.9.0
