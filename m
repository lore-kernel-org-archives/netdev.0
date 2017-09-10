From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH iproute2 3/3] bridge: request vlans along with link information
Date: Sun, 10 Sep 2017 14:18:47 -0400
Message-ID: <85poayquwo.fsf@mojatatu.com>
References: <1504907543-14394-1-git-send-email-mrv@mojatatu.com>
        <1504907543-14394-4-git-send-email-mrv@mojatatu.com>
        <CAJieiUhT75fM3LuhNW32QkbJA9TO5dHwb_G-aRD2H70jF-FG2A@mail.gmail.com>
        <85y3pmr7wn.fsf@mojatatu.com>
        <93aaf641-5063-e5d2-799c-718c85ca60a5@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        "stephen\@networkplumber.org" <stephen@networkplumber.org>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:45678 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750789AbdIJSS7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2017 14:18:59 -0400
Received: by mail-it0-f45.google.com with SMTP id v19so9821992ite.0
        for <netdev@vger.kernel.org>; Sun, 10 Sep 2017 11:18:59 -0700 (PDT)
In-Reply-To: <93aaf641-5063-e5d2-799c-718c85ca60a5@cumulusnetworks.com>
        (Nikolay Aleksandrov's message of "Sun, 10 Sep 2017 17:21:48 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@cumulusnetworks.com> writes:

> On 10/09/17 16:38, Roman Mashak wrote:

[...]

>> Since VLAN info is already in link messages, there is no other option but
>> dump it in monitor or "bridge link show". Yes, the output may be lengthy
>
> To make sure there's no misunderstanding - on GETLINK the vlan info is _not_
> dumped by default (not compressed or otherwise).

Yes, I understand it, I was referring to link events in the previous
comment. However, why not to report compressed vlans for GETLINK by
default if show_details is true, this would be consistent with events monitor.

It seems to be more clear and intuitive from the user's perspective, the
same set of command line options for \monitor' or 'show' commands.

> It is only dumped compressed on port notifications, that is why I suggested to
> use the already present flag (-compressvlans, -c) in order to include that info
> when monitoring or dumping link info, so people watching for the port flags
> (show_details) would not suddenly start getting a lot more and it makes sense
> to dump it only on specific request.
>
>> and hard to digest for a human, that is why I put it under "show_details"
>> kludge - if one is requesting details, he/she should be prepared for
>> large volumes of data to be shown :)
>> 
>> As Nikolay suggested, it'll make sense to request compressed
>> output by default, this will be addresses in v2 patch.
>> 
>> [...]
>> 
