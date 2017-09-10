From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH iproute2 3/3] bridge: request vlans along with link information
Date: Sun, 10 Sep 2017 09:38:00 -0400
Message-ID: <85y3pmr7wn.fsf@mojatatu.com>
References: <1504907543-14394-1-git-send-email-mrv@mojatatu.com>
        <1504907543-14394-4-git-send-email-mrv@mojatatu.com>
        <CAJieiUhT75fM3LuhNW32QkbJA9TO5dHwb_G-aRD2H70jF-FG2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "stephen\@networkplumber.org" <stephen@networkplumber.org>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:38160 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750853AbdIJNi1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2017 09:38:27 -0400
Received: by mail-io0-f193.google.com with SMTP id j141so2111149ioj.5
        for <netdev@vger.kernel.org>; Sun, 10 Sep 2017 06:38:27 -0700 (PDT)
In-Reply-To: <CAJieiUhT75fM3LuhNW32QkbJA9TO5dHwb_G-aRD2H70jF-FG2A@mail.gmail.com>
        (Roopa Prabhu's message of "Sat, 9 Sep 2017 09:24:31 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roopa Prabhu <roopa@cumulusnetworks.com> writes:

> On Fri, Sep 8, 2017 at 2:52 PM, Roman Mashak <mrv@mojatatu.com> wrote:
>> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
>> ---
>>  bridge/link.c | 16 +++++++++++++---
>>  1 file changed, 13 insertions(+), 3 deletions(-)
>>
>> diff --git a/bridge/link.c b/bridge/link.c
>> index 60200f1..9e4206f 100644
>> --- a/bridge/link.c
>> +++ b/bridge/link.c
>> @@ -461,9 +461,19 @@ static int brlink_show(int argc, char **argv)
>>                 }
>>         }
>>
>> -       if (rtnl_wilddump_request(&rth, PF_BRIDGE, RTM_GETLINK) < 0) {
>> -               perror("Cannon send dump request");
>> -               exit(1);
>> +       if (show_details) {
>> +               if (rtnl_wilddump_req_filter(&rth, PF_BRIDGE, RTM_GETLINK,
>> +                                            (compress_vlans ?
>> +                                             RTEXT_FILTER_BRVLAN_COMPRESSED :
>> +                                             RTEXT_FILTER_BRVLAN)) < 0) {
>> +                       perror("Cannon send dump request");
>> +                       exit(1);
>> +               }
>
> vlan information is already available with `bridge vlan show`. any
> specific reason why you want it in
> the link dump output ?

Since VLAN info is already in link messages, there is no other option but
dump it in monitor or "bridge link show". Yes, the output may be lengthy
and hard to digest for a human, that is why I put it under "show_details"
kludge - if one is requesting details, he/she should be prepared for
large volumes of data to be shown :)

As Nikolay suggested, it'll make sense to request compressed
output by default, this will be addresses in v2 patch.

[...]
