From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] rtnl: Add support for netdev event to link
 messages
Date: Thu, 30 Mar 2017 08:11:23 -0600
Message-ID: <91c304f6-659f-01d7-a899-171142075276@cumulusnetworks.com>
References: <1490493587-25819-1-git-send-email-vyasevic@redhat.com>
 <20170327.155835.1930829109806331326.davem@davemloft.net>
 <2fe31fc9-2837-91a7-e2a4-7937bb15cf3d@redhat.com>
 <58DBE2D9.10509@cumulusnetworks.com>
 <8c2ab762-5b76-7a70-a096-51529d8a3edb@redhat.com>
 <22cf1543-505e-bae0-4efb-dfdd501399c0@cumulusnetworks.com>
 <55cb61be-53af-315c-a376-e8f1d7bc78a6@redhat.com>
 <59f24d68-cff1-d8a5-a7f6-8173057f57d8@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: vyasevic@redhat.com, Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35372 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933107AbdC3OL1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 10:11:27 -0400
Received: by mail-pg0-f42.google.com with SMTP id 81so41068160pgh.2
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 07:11:26 -0700 (PDT)
In-Reply-To: <59f24d68-cff1-d8a5-a7f6-8173057f57d8@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/30/17 7:47 AM, Vlad Yasevich wrote:
>>>>> But, NETDEV_PRECHANGEMTU will be a unnecessary notification to userspace without
>>>>> changes. There are already enough notifications generated for links (I know you are not
>>>>> suggesting adding it here)
>>>>
>>>> Actually, this one already triggers a link notification to userspace.  It just has
>>>> no event data in it to tell you that. :)
>>>
>>> Is it intentional or unintentional? perhaps rtnetlink_event should be a
>>> whitelist -- events that userspace should be notified about. Seems like
>>> NETDEV_ events have been added without rtnetlink_event getting updated.
>>
>> I think a 'whitelist' was attempted, but as you mentioned, it hasn't been updated...
>> I'll defer the definitive answer to someone else.  It seems Patrick added a comment
>> in commit a2835763 to update the white list and it's been a few times.
>>
> 
> This is actually an interesting point.  Looking at some commits that have added
> events to black list in rtnetlink-event, it might have been much easier to debug
> those issues if we had the 'event' encoding in the netlink message.
> 
> I think it might be worthwhile to add all allowed event types to this new encoding
> so we can userspace can see just what's its getting.
> 

My point is that it is easy to add NETDEV events; takes extra effort to
update rtnetlink_event to say "don't send a notification to userspace".

A number of those events are for kernel processing, so why send anything
to userspace? In that case a default of don't notify userspace and then
having a list of events that should send the notification makes the
intent explicit.

Looking at git commit logs for NETDEV_PRECHANGEMTU, it seems that it was
added for bonding and teaming to simplify kernel processing; userspace
does not need to be notified so no intention there.
