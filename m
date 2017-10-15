From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 0/6] rtnetlink: a bunch of fixes for userspace notifications in changing dev properties
Date: Sun, 15 Oct 2017 18:13:40 +0800
Message-ID: <cover.1508062280.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, David Ahern <dsahern@gmail.com>,
        hannes@stressinduktion.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:57179 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750722AbdJOKNz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 06:13:55 -0400
Received: by mail-pf0-f193.google.com with SMTP id b85so13630796pfj.13
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 03:13:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whenever any property of a link, address, route, etc. changes by whatever way,
kernel should notify the programs that listen for such events in userspace.

The patchet "rtnetlink: Cleanup user notifications for netdev events" tried to
fix a redundant notifications issue, but it also introduced a side effect.

After that, user notifications could only be sent when changing dev properties
via netlink api. As it removed some events process in rtnetlink_event where
the notifications was sent to users.

It resulted in no notification generated when dev properties are changed via
other ways, like ioctl, sysfs, etc. It may cause some user programs doesn't
work as expected because of the missing notifications.

This patchset will fix it by bringing some of these netdev events back and
also fix the old redundant notifications issue with a proper way.

Xin Long (6):
  rtnetlink: bring NETDEV_CHANGEMTU event process back in
    rtnetlink_event
  rtnetlink: bring NETDEV_CHANGE_TX_QUEUE_LEN event process back in
    rtnetlink_event
  rtnetlink: bring NETDEV_POST_TYPE_CHANGE event process back in
    rtnetlink_event
  rtnetlink: bring NETDEV_CHANGEUPPER event process back in
    rtnetlink_event
  rtnetlink: check DO_SETLINK_NOTIFY correctly in do_setlink
  rtnetlink: do not set notification for tx_queue_len in do_setlink

 net/core/rtnetlink.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

-- 
2.1.0
