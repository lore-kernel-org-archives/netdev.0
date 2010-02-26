From: Patrick McHardy <kaber@trash.net>
Subject: net: rtnetlink: support specifying device flags on device creation
Date: Fri, 26 Feb 2010 17:34:49 +0100 (MET)
Message-ID: <20100226163449.11434.13013.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59360 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965054Ab0BZQeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 11:34:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches add support to specify the device flags (like UP) when
creating a new device through rtnl_link. This requires to surpress netlink
notifications until the device is fully configured in order to not confuse
userspace when changing the flags fails and registration has to be undone.
Once the device is configured, a single NEWLINK message with the full state
is sent.

The individual patch changelogs describe the necessary changes in more detail.


 drivers/net/veth.c        |   15 +++--
 include/linux/netdevice.h |    9 ++-
 include/net/rtnetlink.h   |    2 +
 net/core/dev.c            |  171 +++++++++++++++++++++++++++++----------------
 net/core/rtnetlink.c      |   59 ++++++++++++----
 5 files changed, 176 insertions(+), 80 deletions(-)

Patrick McHardy (4):
      net: rtnetlink: ignore NETDEV_PRE_UP notifier in rtnetlink_event()
      net: rtnetlink: handle rtnl_link netlink notifications manually
      net: dev: support deferring device flag change notifications
      net: rtnetlink: support specifying device flags on device creation
