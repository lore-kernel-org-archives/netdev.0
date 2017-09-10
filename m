From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 3/3] bridge: request vlans along with link information
Date: Sat, 9 Sep 2017 22:28:00 -0700
Message-ID: <CAJieiUhOof4P4FNkxmpQ9BvotNJBuEsAz2Tq4gvZpfgYdhMj1Q@mail.gmail.com>
References: <1504907543-14394-1-git-send-email-mrv@mojatatu.com>
 <1504907543-14394-4-git-send-email-mrv@mojatatu.com> <CAJieiUhT75fM3LuhNW32QkbJA9TO5dHwb_G-aRD2H70jF-FG2A@mail.gmail.com>
 <5706e1ba-6b85-4f32-a858-b5d87b17eb51@mojatatu.com> <1bde7c3e-1571-a2a2-3308-b42906fbb3d2@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Roman Mashak <mrv@mojatatu.com>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:34491 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750807AbdIJF2B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2017 01:28:01 -0400
Received: by mail-oi0-f49.google.com with SMTP id l74so27964006oih.1
        for <netdev@vger.kernel.org>; Sat, 09 Sep 2017 22:28:01 -0700 (PDT)
In-Reply-To: <1bde7c3e-1571-a2a2-3308-b42906fbb3d2@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 9, 2017 at 11:15 AM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> On 09/09/17 20:23, Jamal Hadi Salim wrote:
>> On 17-09-09 12:24 PM, Roopa Prabhu wrote:
>>> On Fri, Sep 8, 2017 at 2:52 PM, Roman Mashak <mrv@mojatatu.com> wrote:
>>>> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
>>>> ---
>

[snip]

>>>
>>> vlan information is already available with `bridge vlan show`. any
>>> specific reason why you want it in
>>> the link dump output ?
>>>
>>>
>>> The problem is this might just make the link dump larger and also add
>>> too much clutter into the regular link dump output. iproute2 detailed
>>> dump is already a bit hard to interpret. And without compression by
>>> default, vlan info can just take over the link dump output. It will be
>>> hard to look for other link attributes after that :). We deploy with
>>> thousands of vlans and without compression even bridge vlan default
>>> output is already hard to interpret.
>>>
>>
>> Agree we should be turning on this stuff by default. i.e default stays
>> compressed; otherwise it a huge dump.
>
> I think this should be dumped with the getlink request only on some additional
> flag. The getlink does not include these by default.
>
>>
>> Having said that there is a lot of mess with this stuff.
>> The bridge link events _already send this IFLA_AF_SPCE info_
>> so not much choice  there but to print it.
>
> Right, on NEWLINK per port notification you'll get the compressed vlan info.
>
>> At minimal we need that part because unfortunately there is no
>> vlanfilter event in existence which will send us summaries of just
>> vlans added to a port i.e both use XXXLINK.
>
> But let's either add a new flag or use -compressvlans to print it when monitoring/showing
> link otherwise people who are monitoring only the port flags will start getting lists
> with vlans. Even compressed these can still be quite long and confusing, especially
> when monitoring.

yes agree. It will add too much clutter to the monitor output too.
