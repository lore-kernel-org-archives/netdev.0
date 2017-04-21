From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v3 net-next 0/2] rtnetlink: Updates to rtnetlink_event()
Date: Fri, 21 Apr 2017 13:31:19 -0400
Message-ID: <1492795881-11914-1-git-send-email-vyasevic@redhat.com>
Cc: dsa@cumulusnetworks.com, Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33150 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1038171AbdDUS3T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:29:19 -0400
Received: by mail-qt0-f193.google.com with SMTP id c45so12938013qtb.0
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:29:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a version 3 series came out of the conversation that started
as a result my first attempt to add netdevice event info to netlink messages.

First, let's clean-up the duplicate notifications for NETDEV_CHANGNAME
event.  We get a message from the event handler as well as a result of
do_setlink().  The two messages are identical, so remove the event.

Second, update the original patch to add IFLA_EVENT attribute
to the link message to only support currently white-listed events.
Like before, this is just an attribute that gets added to the rtnetlink
message only when the messaged was generated as a result of a netdev event.
In my case, this is necessary since I want to trap NETDEV_NOTIFY_PEERS
event (also possibly NETDEV_RESEND_IGMP event) and perform certain actions
in user space.  This is not possible since the messages generated as
a result of netdev events do not usually contain any changed data.  They
are just notifications.  This patch exposes this notification type to
userspace.

I will also update my patch to iproute that will show this data
through 'ip monitor'. 


V3: Rebased.  Cleaned-up duplicate event.

V2: Added missed events (from David Ahern)

Vladislav Yasevich (2):
  rtnetlink: Convert rtnetlink_event to white list
  rtnl: Add support for netdev event to link messages

 include/linux/rtnetlink.h    |   3 +-
 include/uapi/linux/if_link.h |  21 ++++++++
 net/core/dev.c               |   2 +-
 net/core/rtnetlink.c         | 121 +++++++++++++++++++++++++++++++++++--------
 4 files changed, 123 insertions(+), 24 deletions(-)

-- 
2.7.4


Vladislav Yasevich (2):
  rtnetlink: Disable notification for NETDEV_NAMECHANGE event
  rtnl: Add support for netdev event to link messages

 include/linux/rtnetlink.h    |  3 ++-
 include/uapi/linux/if_link.h | 11 ++++++++
 net/core/dev.c               |  2 +-
 net/core/rtnetlink.c         | 63 +++++++++++++++++++++++++++++++++++++-------
 4 files changed, 67 insertions(+), 12 deletions(-)

-- 
2.7.4
