From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 3/3] bridge: request vlans along with link
 information
Date: Sun, 10 Sep 2017 21:36:23 +0300
Message-ID: <5eec2834-c54f-0cc9-e5f7-a38cce6ebee1@cumulusnetworks.com>
References: <1504907543-14394-1-git-send-email-mrv@mojatatu.com>
 <1504907543-14394-4-git-send-email-mrv@mojatatu.com>
 <CAJieiUhT75fM3LuhNW32QkbJA9TO5dHwb_G-aRD2H70jF-FG2A@mail.gmail.com>
 <85y3pmr7wn.fsf@mojatatu.com>
 <93aaf641-5063-e5d2-799c-718c85ca60a5@cumulusnetworks.com>
 <85poayquwo.fsf@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:45147 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750966AbdIJSg0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2017 14:36:26 -0400
Received: by mail-wm0-f50.google.com with SMTP id f199so26765938wme.0
        for <netdev@vger.kernel.org>; Sun, 10 Sep 2017 11:36:25 -0700 (PDT)
In-Reply-To: <85poayquwo.fsf@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/17 21:18, Roman Mashak wrote:
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> writes:
> 
>> On 10/09/17 16:38, Roman Mashak wrote:
> 
> [...]
> 
>>> Since VLAN info is already in link messages, there is no other option but
>>> dump it in monitor or "bridge link show". Yes, the output may be lengthy
>>
>> To make sure there's no misunderstanding - on GETLINK the vlan info is _not_
>> dumped by default (not compressed or otherwise).
> 
> Yes, I understand it, I was referring to link events in the previous
> comment. However, why not to report compressed vlans for GETLINK by
> default if show_details is true, this would be consistent with events monitor.
> 

So my point is to only print the compressed vlans when the -c flag is present on
both occasions. I don't have any strong feeling about this, my only concern is that
people using -d with monitor will start suddenly seeing a lot more than they expect.
The -c (which already exists) will give them the option to skip it. Also the getlink
with lots of vlans and ports will grow by default if there's no way to remove the
vlan dumps (be it compressed or not).

In general I'd prefer to have only one way to do things, e.g. in this particular
case I'd advise people to use bridge vlan show, but I get it that monitor doesn't
show them anywhere. Maybe all of this should go under bridge monitor vlan or
bridge -compressvlans monitor link. Anyway, if other people are fine with extending
the 'show_details' only, then I won't stay in the way.

> It seems to be more clear and intuitive from the user's perspective, the
> same set of command line options for \monitor' or 'show' commands.
> 

That I completely agree with. :-)

>> It is only dumped compressed on port notifications, that is why I suggested to
>> use the already present flag (-compressvlans, -c) in order to include that info
>> when monitoring or dumping link info, so people watching for the port flags
>> (show_details) would not suddenly start getting a lot more and it makes sense
>> to dump it only on specific request.
>>
>>> and hard to digest for a human, that is why I put it under "show_details"
>>> kludge - if one is requesting details, he/she should be prepared for
>>> large volumes of data to be shown :)
>>>
>>> As Nikolay suggested, it'll make sense to request compressed
>>> output by default, this will be addresses in v2 patch.
>>>
>>> [...]
>>>
