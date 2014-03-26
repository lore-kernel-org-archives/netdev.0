From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH v5 0/4] Provide netdev naming-policy via sysfs
Date: Wed, 26 Mar 2014 14:05:13 +0100
Message-ID: <1395839117-20090-1-git-send-email-dh.herrmann@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Gundersen <teg@jklm.no>,
	Johannes berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Herrmann <dh.herrmann@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

This is v5 of the netdev naming-policy series. You can find v4 here:
  http://article.gmane.org/gmane.linux.kernel/1668161
Changes since v4:
  - none


This series implements a new sysfs attribute for netdevs called
"name_assign_type". It provides an integer that describes where an interface
name comes from. See Patch #1 for a description of this attribute. It is
modelled after the existing "addr_assign_type" attribute.

The main use-case is to allow udev to skip applying reliable ifnames to virtual
devices. For instance, if wifi-P2P devices are created, wpas already provides a
suitable naming-policy and udev shouldn't touch these devices. Same is true for
other virtual devices.
The idea is that if a device-name was provided by user-space, we should always
prefer fixing this naming-policy instead of making udev rename the device. For
kernel provided names that's hardly possible, though. Providing the
naming-policy source via sysfs is thus a simple way to see whether renames are
needed.

Additionally, this field allows to detect whether a netdev has been manually
renamed, which is quite useful for debugging and during crash-recovery.
Furthermore, it fixes real udev bugs if a netdev is already renamed in the
initrd and udev only runs in the real root. Detecting renames avoids overwriting
custom user provided names.

Thanks
David

David Herrmann (4):
  net: add name_assign_type netdev attribute
  mac80211: set NET_NAME_USER for user-space created ifs
  ath6kl: set NET_NAME_USER for P2P ifs
  brcmfmac: set NET_NAME_USER for P2P ifs

 drivers/net/wireless/ath/ath6kl/cfg80211.c    | 5 ++++-
 drivers/net/wireless/ath/ath6kl/cfg80211.h    | 1 +
 drivers/net/wireless/ath/ath6kl/core.c        | 4 ++--
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c | 1 +
 include/linux/netdevice.h                     | 2 ++
 include/uapi/linux/netdevice.h                | 4 ++++
 net/core/dev.c                                | 7 +++++++
 net/core/net-sysfs.c                          | 2 ++
 net/core/rtnetlink.c                          | 2 ++
 net/mac80211/cfg.c                            | 2 +-
 net/mac80211/ieee80211_i.h                    | 1 +
 net/mac80211/iface.c                          | 2 ++
 net/mac80211/main.c                           | 2 +-
 13 files changed, 30 insertions(+), 5 deletions(-)

-- 
1.9.1
