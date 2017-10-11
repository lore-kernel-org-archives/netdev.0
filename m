From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [jkirsher/next-queue PATCH v4 0/6] tc-flower based cloud filters
 in i40e
Date: Wed, 11 Oct 2017 22:38:32 +0200
Message-ID: <20171011203832.GA9297@nanopsycho>
References: <150768099999.5320.1633617713417675266.stgit@anamdev.jf.intel.com>
 <20171011125635.GD2039@nanopsycho>
 <CAKgT0UcP8refj2KLMT258xPNS2h3KhLqKD5sJkNLXRdNJrRCVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amritha Nambiar <amritha.nambiar@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        Netdev <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:52136 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751657AbdJKUie (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 16:38:34 -0400
Received: by mail-wm0-f45.google.com with SMTP id f4so8180193wme.0
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 13:38:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAKgT0UcP8refj2KLMT258xPNS2h3KhLqKD5sJkNLXRdNJrRCVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 11, 2017 at 07:46:27PM CEST, alexander.duyck@gmail.com wrote:
>On Wed, Oct 11, 2017 at 5:56 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Wed, Oct 11, 2017 at 02:24:12AM CEST, amritha.nambiar@intel.com wrote:
>>>This patch series enables configuring cloud filters in i40e
>>>using the tc-flower classifier. The classification function
>>>of the filter is to match a packet to a class. cls_flower is
>>>extended to offload classid to hardware. The offloaded classid
>>>is used direct matched packets to a traffic class on the device.
>>>The approach here is similar to the tc 'prio' qdisc which uses
>>>the classid for band selection. The ingress qdisc is called ffff:0,
>>>so traffic classes are ffff:1 to ffff:8 (i40e has max of 8 TCs).
>>
>>
>> NACK. This clearly looks like abuse of classid to something
>> else. Classid is here to identify qdisc instance. However, you use it
>> for hw tclass identification. This is mixing of apples and oranges.
>>
>> Why?
>>
>> Please don't try to abuse things! This is not nice.
>
>This isn't an abuse. This is reproducing in hardware what is already
>the behavior for software. Isn't that how offloads are supposed to
>work?

What is meaning of classid in HW? Classid is SW only identification of
qdisc instances. No relation to HW instances = abuse.


>
>This is exactly how prio currently handles this. We are essentially
>doing the exact same thing in the hardware where we are choosing a
>queueing group based on the class ID. You could setup a prio qdisc. If
>you are offloading a qdisc behavior into hardware how are you supposed
>to emulate the behavior if you aren't allowing the offload to use the
>same mechanism?

I believe that the correct way to solve is to introduce SETTCLASS
termination action (similar to TRAP, GOTO_CHAIN, etc), which would allow
user to instruct the destination tclass and driver can offload it.
