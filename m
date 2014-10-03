From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v4 net-next 0/3] bridge: Add vlan filtering support for default pvid
Date: Fri,  3 Oct 2014 11:29:15 -0400
Message-ID: <1412350158-19061-1-git-send-email-vyasevic@redhat.com>
Cc: stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	toshiaki.makita1@gmail.com, cwang@twopensource.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:50454 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbaJCP32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 11:29:28 -0400
Received: by mail-qg0-f44.google.com with SMTP id j5so1120727qga.3
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 08:29:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds default pvid support to vlan filtering in the bridge.
VLAN 1 (as recommended by 802.1q spec) is used as default pvid on ports. 
The the user can over-ride this configuration by configuring their
own vlan information. 
The user can additionally change the default value throught the
sysfs interface (netlink comming shortly).
The user can turn off default pvid functionality by setting default
pvid to 0. 
This series changes the default behavior of the bridge when
vlan filtering is turned on.  Currently, ports without any vlan
filtering configured will not recevie any traffic at all.  This patch
changes the behavior of the above ports to receive only untagged traffic.

Since v3:
- allocated 'changed' bitmap on the heap and re-arrange code to clean it up.
- remove extra blank lines.
- Fix patch1 to build by itself.
- Fix error recover to not add vlan 0.
- Restructure nbp_vlan_init to remove uneeded variable.

Since v2:
- Fix handling of invalid values in sysfs interface.
- Add some additional log messages.
- Fix default_pvid handling when vlan filtering is compiled out.
- Fix sparse issues with new code.
- Fix how we located the old default pvid (added a helper function).

Since v1:
- Add ability to turn off default_pvid settings.
- Drop the automiatic filtering support based on configured vlan devices (will
  be its own series)

Thanks
-vlad

Vladislav Yasevich (3):
  bridge: Add a default_pvid sysfs attribute
  bridge: Simplify pvid checks.
  bridge: Add filtering support for default_pvid

 net/bridge/br_device.c   |   8 ++-
 net/bridge/br_if.c       |   3 +
 net/bridge/br_private.h  |  23 +++++---
 net/bridge/br_sysfs_br.c |  17 ++++++
 net/bridge/br_vlan.c     | 148 ++++++++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 187 insertions(+), 12 deletions(-)

-- 
1.9.3
