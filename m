From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] rtnl: Add support for netdev event to link messages
Date: Wed, 29 Mar 2017 09:37:45 -0700
Message-ID: <58DBE2D9.10509@cumulusnetworks.com>
References: <1490493587-25819-1-git-send-email-vyasevic@redhat.com> <20170327.155835.1930829109806331326.davem@davemloft.net> <2fe31fc9-2837-91a7-e2a4-7937bb15cf3d@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33114 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752264AbdC2Qhs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 12:37:48 -0400
Received: by mail-pf0-f173.google.com with SMTP id s16so10093699pfs.0
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 09:37:47 -0700 (PDT)
In-Reply-To: <2fe31fc9-2837-91a7-e2a4-7937bb15cf3d@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/29/17, 5:23 AM, Vlad Yasevich wrote:
> [ resending to list.  hit the wrong reply button last time ]
>
> On 03/27/2017 06:58 PM, David Miller wrote:
>> From: Vladislav Yasevich <vyasevich@gmail.com>
>> Date: Sat, 25 Mar 2017 21:59:47 -0400
>>
>>> RTNL currently generates notifications on some netdev notifier events.
>>> However, user space has no idea what changed.  All it sees is the
>>> data and has to infer what has changed.  For some events that is not
>>> possible.
>>>
>>> This patch adds a new field to RTM_NEWLINK message called IFLA_EVENT
>>> that would have an encoding of the which event triggered this
>>> notification.  Currectly, only 2 events (NETDEV_NOTIFY_PEERS and
>>> NETDEV_MTUCHANGED) are supported.  These events could be interesting
>>> in the virt space to trigger additional configuration commands to VMs.
>>> Other events of interest may be added later.
>>>
>>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>> At what point do we start providing the metadata for the changed
>> values as well?  You'd probably need to provide both the old and
>> new values to cover all cases.
> I don't think if that would be possible because of when events are triggered.
> We send these notifications after all the changes have already been made, so
> it might be tough to carry old data.
>
> Looking at just the two events I am supporting in this patch, we could actually
> supply the old mtu data through a NETDEV_PRECHANGEMTU event, if it is necessary.

But, NETDEV_PRECHANGEMTU will be a unnecessary notification to userspace without
changes. There are already enough notifications generated for links (I know you are not
suggesting adding it here)
> For the use cases I am looking at, it isn't usefull, but easy enough to add.
>
Most of the times a single notification can carry multiple changes, this helps user-space..by
cutting down on notifications in systems with large number of links. I don't see IFLA_EVENT attribute
handle multiple changes..

Given the number of attributes for which events are generated, I think a model where user-space
maintains a cache and diff's the new link object with the old one works best in all cases.
