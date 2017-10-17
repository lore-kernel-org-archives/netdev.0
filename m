From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 0/3] bonding: void calling rtmsg_ifinfo for netlink notifications
Date: Tue, 17 Oct 2017 17:39:38 +0800
Message-ID: <cover.1508233044.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Jiri Pirko <jiri@resnulli.us>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:48401 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934791AbdJQJju (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 05:39:50 -0400
Received: by mail-pf0-f193.google.com with SMTP id b79so952976pfk.5
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 02:39:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's better to send notifications to userspace by the events
in rtnetlink_event, instead of calling rtmsg_ifinfo directly.

This patcheset is to remove rtmsg_ifinfo called in bonding,
the notifications can be handled by NETDEV_CHANGEUPPER and
NETDEV_CHANGELOWERSTATE events in rtnetlink_event.

It could also fix some redundant notifications from bonding.

Xin Long (3):
  bonding: remove rtmsg_ifinfo called in bond_master_upper_dev_link
  rtnetlink: bring NETDEV_CHANGELOWERSTATE event process back to
    rtnetlink_event
  bonding: remove rtmsg_ifinfo called after bond_lower_state_changed

 drivers/net/bonding/bond_main.c | 11 +++--------
 include/net/bonding.h           |  4 ----
 net/core/rtnetlink.c            |  2 +-
 3 files changed, 4 insertions(+), 13 deletions(-)

-- 
2.1.0
