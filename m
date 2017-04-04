From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net-next 0/2] rtnetlink: Updates to rtnetlink_event()
Date: Tue,  4 Apr 2017 09:23:43 -0400
Message-ID: <1491312223-18772-4-git-send-email-vyasevic@redhat.com>
References: <1491312223-18772-1-git-send-email-vyasevic@redhat.com>
Cc: roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        davem@davemloft.net, Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36840 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753672AbdDDNY3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 09:24:29 -0400
Received: by mail-qt0-f193.google.com with SMTP id n37so23215268qtb.3
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 06:24:29 -0700 (PDT)
In-Reply-To: <1491312223-18772-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series came out of the conversation that started as a result
my first attempt to add netdevice event info to netlink messages.

This series converts event processing to a 'white list', where
we explicitely permit events to generate netlink messages.  This
is meant to make people take a closer look and determine wheter
these events should really trigger netlink messages.

I am also adding a V2 of my patch to add event type to the netlink
message.  This version supports all events that we currently generate.

I will also update my patch to iproute that will show this data
through 'ip monitor'. 

I actually need the ability to trap NETDEV_NOTIFY_PEERS event
(as well as possible NETDEV_RESEND_IGMP) to support hanlding of
macvtap on top of bonding.  I hope others will also find this info usefull.

Vladislav Yasevich (2):
  rtnetlink: Convert rtnetlink_event to white list
  rtnl: Add support for netdev event to link messages

 include/linux/rtnetlink.h    |   3 +-
 include/uapi/linux/if_link.h |  19 ++++++++
 net/core/dev.c               |   2 +-
 net/core/rtnetlink.c         | 113 ++++++++++++++++++++++++++++++++++---------
 4 files changed, 113 insertions(+), 24 deletions(-)

-- 
2.7.4
