From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 0/4] net: ipv6: Improve user experience with
 multipath routes
Date: Mon, 30 Jan 2017 07:45:07 -0800
Message-ID: <588F5F83.3050304@cumulusnetworks.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com> <588D3EB9.1070107@cumulusnetworks.com> <592be6dc-df0e-6185-ba6f-5acf5d042ae5@cumulusnetworks.com> <588E80DB.3070209@cumulusnetworks.com> <7a7dcae4-a01b-3217-3296-b0aa2c7052f3@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:35575 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932415AbdA3PpY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 10:45:24 -0500
Received: by mail-pg0-f52.google.com with SMTP id 194so102041753pgd.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 07:45:08 -0800 (PST)
In-Reply-To: <7a7dcae4-a01b-3217-3296-b0aa2c7052f3@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/17, 3:08 AM, Nicolas Dichtel wrote:
> Le 30/01/2017 à 00:55, Roopa Prabhu a écrit :
>> On 1/29/17, 10:02 AM, David Ahern wrote:
>>> On 1/28/17 6:00 PM, Roopa Prabhu wrote:
>>>>> 4. Route Appends
>>>>>    - IPv6 allows nexthops to be appended to an existing route. In this
>>>>>      case one notification is sent per nexthop added
>>>> thanks for listing all of these...I think you mentioned this case to me..
>>>> but I don't remember now why this notification is
>>>> sent per nexthop added. This is an update to an existing multipath route.
>>>> so seems like the notification should be a RTM_NEWROUTE with the full RTA_MULTIPATH route
>>>> (similar to route add)
>>> It could be; it's a question of what should userspace get -- the full route or the change? Append to me suggests the latter - userspace is told what changed. It is simpler kernel code wise to send the full new route. The append changes were done after our conversation. ;-)
>> ok, yeah. you listing all the cases here made it more simpler to understand in the context of other notifications :). I would prefer all
>> RTM_NEWLINK notifications (ie new add or update to an existing route..replace/append), contain the full route via RTA_MULTIPATH.
> I don't agree. With the previous proposal, you know *exactly* what happens with
> each notification and this is the primary goal of the notifications. With the
> last proposal, where RTA_MULTIPATH is used for replace and append, you have the
> new result, but you don't know what has been done.
> Usually, notifications are used to notify an event, not the result of an event.
> If you want the result, you can use the dump cmd.

what has been done is conveyed by the APPEND and REPLACE flag in the notification. The user only cares about the updated multipath route...
giving parts of the route has never been very useful... and this is consistent with ipv4.
