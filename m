From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net 0/3] bonding: void calling rtmsg_ifinfo for netlink notifications
Date: Tue, 17 Oct 2017 18:28:45 +0800
Message-ID: <CADvbK_c7R2OJNq=DyXOCSNVzD2aU2qxBO6UiitGbCYS=icwxTQ@mail.gmail.com>
References: <cover.1508233044.git.lucien.xin@gmail.com> <20171017095943.GE2112@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:49392 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761125AbdJQK2q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 06:28:46 -0400
Received: by mail-qt0-f196.google.com with SMTP id k31so2366088qta.6
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 03:28:46 -0700 (PDT)
In-Reply-To: <20171017095943.GE2112@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 5:59 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Oct 17, 2017 at 11:39:38AM CEST, lucien.xin@gmail.com wrote:
>>It's better to send notifications to userspace by the events
>>in rtnetlink_event, instead of calling rtmsg_ifinfo directly.
>>
>>This patcheset is to remove rtmsg_ifinfo called in bonding,
>>the notifications can be handled by NETDEV_CHANGEUPPER and
>>NETDEV_CHANGELOWERSTATE events in rtnetlink_event.
>>
>>It could also fix some redundant notifications from bonding.
>
> This should go to net-next.

NETDEV_CHANGEUPPER is not yet in rtnetlink_event in net-next tree.
patches can only work on net tree by now.

Hi, David, you want me to hold them until the patches for NETDEV_CHANGEUPPER
are copied to net-next, or you would apply them to net ?

>
>
>>
>>Xin Long (3):
>>  bonding: remove rtmsg_ifinfo called in bond_master_upper_dev_link
>>  rtnetlink: bring NETDEV_CHANGELOWERSTATE event process back to
>>    rtnetlink_event
>>  bonding: remove rtmsg_ifinfo called after bond_lower_state_changed
>>
>> drivers/net/bonding/bond_main.c | 11 +++--------
>> include/net/bonding.h           |  4 ----
>> net/core/rtnetlink.c            |  2 +-
>> 3 files changed, 4 insertions(+), 13 deletions(-)
>>
>>--
>>2.1.0
>>
