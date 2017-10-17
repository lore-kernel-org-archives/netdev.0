From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net 0/3] bonding: void calling rtmsg_ifinfo for netlink
 notifications
Date: Tue, 17 Oct 2017 12:38:06 +0200
Message-ID: <20171017103806.GG2112@nanopsycho>
References: <cover.1508233044.git.lucien.xin@gmail.com>
 <20171017095943.GE2112@nanopsycho>
 <CADvbK_c7R2OJNq=DyXOCSNVzD2aU2qxBO6UiitGbCYS=icwxTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:57278 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751973AbdJQKiI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 06:38:08 -0400
Received: by mail-wr0-f195.google.com with SMTP id r79so1121193wrb.13
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 03:38:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CADvbK_c7R2OJNq=DyXOCSNVzD2aU2qxBO6UiitGbCYS=icwxTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 17, 2017 at 12:28:45PM CEST, lucien.xin@gmail.com wrote:
>On Tue, Oct 17, 2017 at 5:59 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Tue, Oct 17, 2017 at 11:39:38AM CEST, lucien.xin@gmail.com wrote:
>>>It's better to send notifications to userspace by the events
>>>in rtnetlink_event, instead of calling rtmsg_ifinfo directly.
>>>
>>>This patcheset is to remove rtmsg_ifinfo called in bonding,
>>>the notifications can be handled by NETDEV_CHANGEUPPER and
>>>NETDEV_CHANGELOWERSTATE events in rtnetlink_event.
>>>
>>>It could also fix some redundant notifications from bonding.
>>
>> This should go to net-next.
>
>NETDEV_CHANGEUPPER is not yet in rtnetlink_event in net-next tree.
>patches can only work on net tree by now.
>
>Hi, David, you want me to hold them until the patches for NETDEV_CHANGEUPPER
>are copied to net-next, or you would apply them to net ?

This patchset is not fix right? I see no "Fixes" line. You should wait
until the dependency is merged to net-next, rebase, post for net-next.



>
>>
>>
>>>
>>>Xin Long (3):
>>>  bonding: remove rtmsg_ifinfo called in bond_master_upper_dev_link
>>>  rtnetlink: bring NETDEV_CHANGELOWERSTATE event process back to
>>>    rtnetlink_event
>>>  bonding: remove rtmsg_ifinfo called after bond_lower_state_changed
>>>
>>> drivers/net/bonding/bond_main.c | 11 +++--------
>>> include/net/bonding.h           |  4 ----
>>> net/core/rtnetlink.c            |  2 +-
>>> 3 files changed, 4 insertions(+), 13 deletions(-)
>>>
>>>--
>>>2.1.0
>>>
