From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] rtnl: Add support for netdev event to link
 messages
Date: Wed, 29 Mar 2017 13:11:37 -0600
Message-ID: <22cf1543-505e-bae0-4efb-dfdd501399c0@cumulusnetworks.com>
References: <1490493587-25819-1-git-send-email-vyasevic@redhat.com>
 <20170327.155835.1930829109806331326.davem@davemloft.net>
 <2fe31fc9-2837-91a7-e2a4-7937bb15cf3d@redhat.com>
 <58DBE2D9.10509@cumulusnetworks.com>
 <8c2ab762-5b76-7a70-a096-51529d8a3edb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: vyasevic@redhat.com, Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34787 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752592AbdC2TLk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 15:11:40 -0400
Received: by mail-pg0-f48.google.com with SMTP id 21so15970063pgg.1
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 12:11:39 -0700 (PDT)
In-Reply-To: <8c2ab762-5b76-7a70-a096-51529d8a3edb@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/29/17 11:05 AM, Vlad Yasevich wrote:
> On 03/29/2017 12:37 PM, Roopa Prabhu wrote:
>> On 3/29/17, 5:23 AM, Vlad Yasevich wrote:
>>> [ resending to list.  hit the wrong reply button last time ]
>>>
>>> On 03/27/2017 06:58 PM, David Miller wrote:
>>>> From: Vladislav Yasevich <vyasevich@gmail.com>
>>>> Date: Sat, 25 Mar 2017 21:59:47 -0400
>>>>
>>>>> RTNL currently generates notifications on some netdev notifier events.
>>>>> However, user space has no idea what changed.  All it sees is the
>>>>> data and has to infer what has changed.  For some events that is not
>>>>> possible.
>>>>>
>>>>> This patch adds a new field to RTM_NEWLINK message called IFLA_EVENT
>>>>> that would have an encoding of the which event triggered this
>>>>> notification.  Currectly, only 2 events (NETDEV_NOTIFY_PEERS and
>>>>> NETDEV_MTUCHANGED) are supported.  These events could be interesting
>>>>> in the virt space to trigger additional configuration commands to VMs.
>>>>> Other events of interest may be added later.
>>>>>
>>>>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>>>> At what point do we start providing the metadata for the changed
>>>> values as well?  You'd probably need to provide both the old and
>>>> new values to cover all cases.
>>> I don't think if that would be possible because of when events are triggered.
>>> We send these notifications after all the changes have already been made, so
>>> it might be tough to carry old data.
>>>
>>> Looking at just the two events I am supporting in this patch, we could actually
>>> supply the old mtu data through a NETDEV_PRECHANGEMTU event, if it is necessary.
>>
>> But, NETDEV_PRECHANGEMTU will be a unnecessary notification to userspace without
>> changes. There are already enough notifications generated for links (I know you are not
>> suggesting adding it here)
> 
> Actually, this one already triggers a link notification to userspace.  It just has
> no event data in it to tell you that. :)

Is it intentional or unintentional? perhaps rtnetlink_event should be a
whitelist -- events that userspace should be notified about. Seems like
NETDEV_ events have been added without rtnetlink_event getting updated.
For example, does userspace care about NETDEV_UDP_TUNNEL_PUSH_INFO or
NETDEV_CHANGE_TX_QUEUE_LEN?
