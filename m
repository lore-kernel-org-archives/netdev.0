From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 1/2] mpls: add handlers
Date: Sat, 12 Aug 2017 20:29:18 -0700
Message-ID: <CAJieiUijsyWjzNL=oFaGxtuos367v0VrpSaEqwHvVacrk5hcTA@mail.gmail.com>
References: <1502396917-14848-1-git-send-email-amine.kherbouche@6wind.com>
 <1502396917-14848-2-git-send-email-amine.kherbouche@6wind.com>
 <20170811123405.GY773745@eidolon> <CAJieiUiDN0pk2GDb2+jBQzbjdPTpckSm23SCFGZ9mRHWfQ1H4w@mail.gmail.com>
 <c6fc221b-c0fa-1dbc-d1e2-a746b722dcd7@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Lamparter <equinox@diac24.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Amine Kherbouche <amine.kherbouche@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f177.google.com ([209.85.217.177]:35882 "EHLO
        mail-ua0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752221AbdHMD3T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2017 23:29:19 -0400
Received: by mail-ua0-f177.google.com with SMTP id k43so27017047uaf.3
        for <netdev@vger.kernel.org>; Sat, 12 Aug 2017 20:29:19 -0700 (PDT)
In-Reply-To: <c6fc221b-c0fa-1dbc-d1e2-a746b722dcd7@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 12, 2017 at 6:35 AM, Amine Kherbouche
<amine.kherbouche@6wind.com> wrote:
>
>
> On 11/08/2017 16:37, Roopa Prabhu wrote:
>>
>> On Fri, Aug 11, 2017 at 5:34 AM, David Lamparter <equinox@diac24.net>
>> wrote:
>>>
>>> On Thu, Aug 10, 2017 at 10:28:36PM +0200, Amine Kherbouche wrote:
>>>>
>>>> Mpls handler allows creation/deletion of mpls routes without using
>>>> rtnetlink. When an incoming mpls packet matches this route, the saved
>>>> function handler is called.
>>>
>>> Since I originally authored this patch, I have come to believe that it
>>> might be unneccessarily complicated.  It is unlikely that a lot of
>>> different "handlers" will exist here;  the only things I can think of
>>> are VPLS support and BIER-MPLS multicast replication.  I'm not saying
>>> it's a bad idea, but, well, this was in the README that I gave to 6WIND
>>> with this code:
>>>
>>> ...
>>
>> yes, I would also prefer just exporting the functions  and calling
>> them directly instead of adding a
>> handler layer. We can move to that later if it becomes necessary.
>
> I understand that the handler layer is an overhead (as said by David's
> note), and I agree with the solution for exporting the mpls functions that
> allows route creation/deletion, but how about forwarding the right mpls
> packet to the right vpls device with the device ptr? I don't see
> another way.


hmm...ok, so you are adding a mpls route to get into vpls_rcv and you
want this route to carry the vpls_rcv information. Ideally if you knew
the route is pointing to a vpls device kind, you can directly call
vpls_rcv.
But, am not sure if a route is necessary here either.

It just seems like the vpls device information is duplicated in the
mpls route per vpls dev. Wondering if we can skip the route part and
always do a lookup on vpls-id/label in mpls_rcv to send it to a
vpls_rcv if there is a match.  This will be the l2 handler for mpls.
