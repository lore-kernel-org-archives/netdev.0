From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 0/8] rtnetlink: Cleanup user notifications for netdev events
Date: Tue, 11 Apr 2017 17:02:39 -0700
Message-ID: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:32800 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752498AbdDLACw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 20:02:52 -0400
Received: by mail-pg0-f42.google.com with SMTP id x125so5895439pgb.0
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 17:02:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad's recent patch to add the event type to rtnetlink notifications
points out a number of redundant or unnecessary notifications sent to
userspace for events that are essentially internal to the kernel. Trim
the list to put a dent in the notification storm.

v2
- rebased to top of net-next with IFLA_EVENT patch reverted
- dropped removal NETDEV_CHANGEINFODATA since it is intentionally
  only to send a message to userspace
- dropped NOTIFY_PEERS since Vlad's says it is needed for macvlans
- add patches to remove NETDEV_CHANGEUPPER and NETDEV_CHANGE_TX_QUEUE_LEN
  from the event list

David Ahern (8):
  rtnetlink: Do not generate notifications for MTU events
  rtnetlink: Do not generate notification for UDP_TUNNEL_PUSH_INFO
  rtnetlink: Do not generate notifications for CHANGEADDR event
  rtnetlink: Do not generate notifications for POST_TYPE_CHANGE event
  rtnetlink: Do not generate notifications for PRECHANGEUPPER event
  rtnetlink: Do not generate notifications for CHANGELOWERSTATE event
  rtnetlink: Do not generate notifications for NETDEV_CHANGEUPPER event
  rtnetlink: Do not generate notifications for
    NETDEV_CHANGE_TX_QUEUE_LEN event

 net/core/rtnetlink.c | 9 ---------
 1 file changed, 9 deletions(-)

-- 
2.1.4
