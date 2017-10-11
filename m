From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [jkirsher/next-queue PATCH v4 0/6] tc-flower based cloud filters
 in i40e
Date: Wed, 11 Oct 2017 22:58:30 +0200
Message-ID: <20171011205830.GD9297@nanopsycho>
References: <20171011125635.GD2039@nanopsycho>
 <CAKgT0UcP8refj2KLMT258xPNS2h3KhLqKD5sJkNLXRdNJrRCVg@mail.gmail.com>
 <20171011203832.GA9297@nanopsycho>
 <20171011.134652.1653141099248918341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.duyck@gmail.com, amritha.nambiar@intel.com,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
        alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:53686 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751386AbdJKU6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 16:58:32 -0400
Received: by mail-wm0-f46.google.com with SMTP id q132so8264343wmd.2
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 13:58:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171011.134652.1653141099248918341.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 11, 2017 at 10:46:52PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Wed, 11 Oct 2017 22:38:32 +0200
>
>> Wed, Oct 11, 2017 at 07:46:27PM CEST, alexander.duyck@gmail.com wrote:
>>>On Wed, Oct 11, 2017 at 5:56 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Wed, Oct 11, 2017 at 02:24:12AM CEST, amritha.nambiar@intel.com wrote:
>>>>>This patch series enables configuring cloud filters in i40e
>>>>>using the tc-flower classifier. The classification function
>>>>>of the filter is to match a packet to a class. cls_flower is
>>>>>extended to offload classid to hardware. The offloaded classid
>>>>>is used direct matched packets to a traffic class on the device.
>>>>>The approach here is similar to the tc 'prio' qdisc which uses
>>>>>the classid for band selection. The ingress qdisc is called ffff:0,
>>>>>so traffic classes are ffff:1 to ffff:8 (i40e has max of 8 TCs).
>>>>
>>>>
>>>> NACK. This clearly looks like abuse of classid to something
>>>> else. Classid is here to identify qdisc instance. However, you use it
>>>> for hw tclass identification. This is mixing of apples and oranges.
>>>>
>>>> Why?
>>>>
>>>> Please don't try to abuse things! This is not nice.
>>>
>>>This isn't an abuse. This is reproducing in hardware what is already
>>>the behavior for software. Isn't that how offloads are supposed to
>>>work?
>> 
>> What is meaning of classid in HW? Classid is SW only identification of
>> qdisc instances. No relation to HW instances = abuse.
>
>Jiri I really don't see what the problem is.
>
>As long as the driver does the right thing when changes are made to the
>qdisc, it doesn't really matter what "key" they use to refer to it.
>
>It could have just as easily used the qdisc pointer and then internally
>use some IDR allocated ID to refer to it in the driver and hardware.
>
>But that's such a waste, we have a unique handle already so why can't
>the driver just use that?

Well if I see classid, I expect it should refer to qdisc instance. So
far, this has been always a case. But for some drivers, this would mean
something totally different and unrelated. So what should I think?
What's next? Classid could be abused to identify something else. I don't
understand why.

classid in kernel and tclass in hw are 2 completely unrelated things.
Why they should share the same userspace api? What am I missing that
indicates this is not an abuse?

There should be clean and well-defined userspace api:
1) classid to identify qdisc instances
2) something else to identify HW tclasses
