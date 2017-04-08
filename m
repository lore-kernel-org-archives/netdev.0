From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/8] rtnetlink: Do not generate notifications for
 MTU events
Date: Sat, 8 Apr 2017 14:13:55 -0400
Message-ID: <63e0a6c1-ec09-4f04-7e41-edd0adf871b2@cumulusnetworks.com>
References: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
 <1491600340-8359-2-git-send-email-dsa@cumulusnetworks.com>
 <58E92699.6090909@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com, davem@davemloft.net
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:32880 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751863AbdDHSN5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 14:13:57 -0400
Received: by mail-io0-f178.google.com with SMTP id t68so31579942iof.0
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 11:13:57 -0700 (PDT)
In-Reply-To: <58E92699.6090909@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/8/17 2:06 PM, Roopa Prabhu wrote:
> On 4/7/17, 2:25 PM, David Ahern wrote:
>> Changing MTU on a link currently causes 3 messages to be sent to userspace:
>>
>> [LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1490 qdisc noqueue state UNKNOWN group default event PRE_CHANGE_MTU
>>     link/ether f2:52:5c:6d:21:f3 brd ff:ff:ff:ff:ff:ff
>>
>> [LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default event CHANGE_MTU
>>     link/ether f2:52:5c:6d:21:f3 brd ff:ff:ff:ff:ff:ff
>>
>> [LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
>>     link/ether f2:52:5c:6d:21:f3 brd ff:ff:ff:ff:ff:ff
>>
>> Remove the PRE_CHANGE_MTU and CHANGE_MTU messages.
>>
>>
> 
> This change is good... multiple notifications for the same event does not help in large scale links setups. However, this
> reverts what vlad was trying to do with his patchset. Vlad's patch-set relies on the rtnl notifications generated from
> notifiers (rtnetlink_event) to add  specific event (IFLA_EVENT) in notifications.
> 
> The third notification in your example above is the correct one and is an aggregate notification for a set of changes, but
> it cannot really fill in all types of events in the single IFLA_EVENT attribute as it stands today.  IFLA_EVENT should be
> a bitmask to include all events in this case (i had indicated this in vlads first version).
> 

Agreed. I think it would be best to revert def12888c161 before the UAPI
goes out.

The change can instead add the IFLA_EVENT as a bitmask mentioned here to
note the changes in a setlink. On top of that, remove the notifications
for the events I mentioned in this set to reduce the overhead on userspace.
