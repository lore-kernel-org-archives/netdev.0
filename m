From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v3 0/4] net: ipv6: Improve user experience with
 multipath routes
Date: Mon, 30 Jan 2017 12:13:54 +0100
Message-ID: <ef322f4a-07d7-31af-b402-769b0f446fc7@6wind.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
 <588D3EB9.1070107@cumulusnetworks.com>
 <592be6dc-df0e-6185-ba6f-5acf5d042ae5@cumulusnetworks.com>
 <588E80DB.3070209@cumulusnetworks.com>
 <71e661bd-e26d-2629-06bb-888f6a09b06d@cumulusnetworks.com>
 <588EA2E8.2040302@cumulusnetworks.com>
 <5be4a78e-64b8-abc4-4015-6751a2bab12b@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35541 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751395AbdA3LWn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 06:22:43 -0500
Received: by mail-wm0-f53.google.com with SMTP id b65so28047423wmf.0
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 03:22:28 -0800 (PST)
In-Reply-To: <5be4a78e-64b8-abc4-4015-6751a2bab12b@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/01/2017 à 03:57, David Ahern a écrit :
> On 1/29/17 7:20 PM, Roopa Prabhu wrote:
>>> 2. Delete - 1 notification for each hop for all combinations of delete commands
>>
>> here I was trying to say, for people deleting the full multipath route, you should send a RTA_MULTIPATH.
> 
> The only way to do that is to call inet6_rt_notify() *before* the route delete work has been done in fib6_del_route. Right now it is called at the end - after all sibling associations have been dropped, a time in which it can no longer fill in RTA_MULTIPATH.
> 
> fib6_del_route function does not have any failure paths and is called with the write lock held, so moving the notification might be ok. But it also means ignoring all subsequent failures from fib6_del, again which might be ok since the only failure is ENOENT which can not happen if we are walking the sibling list.
Is it not possible to prepare the RTA_MULTIPATH attribute during the deletion
(when needed information are still available) and to use/copy it later when the
notification is done?

Or at least, having RTA_MUTLTIPATH with one nexthop only, so that the user knows
that this route was part of an ECMP routes?
