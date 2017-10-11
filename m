From: David Miller <davem@davemloft.net>
Subject: Re: [jkirsher/next-queue PATCH v4 0/6] tc-flower based cloud
 filters in i40e
Date: Wed, 11 Oct 2017 13:46:52 -0700 (PDT)
Message-ID: <20171011.134652.1653141099248918341.davem@davemloft.net>
References: <20171011125635.GD2039@nanopsycho>
        <CAKgT0UcP8refj2KLMT258xPNS2h3KhLqKD5sJkNLXRdNJrRCVg@mail.gmail.com>
        <20171011203832.GA9297@nanopsycho>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, amritha.nambiar@intel.com,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
        alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36286 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753054AbdJKUqx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 16:46:53 -0400
In-Reply-To: <20171011203832.GA9297@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 11 Oct 2017 22:38:32 +0200

> Wed, Oct 11, 2017 at 07:46:27PM CEST, alexander.duyck@gmail.com wrote:
>>On Wed, Oct 11, 2017 at 5:56 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Wed, Oct 11, 2017 at 02:24:12AM CEST, amritha.nambiar@intel.com wrote:
>>>>This patch series enables configuring cloud filters in i40e
>>>>using the tc-flower classifier. The classification function
>>>>of the filter is to match a packet to a class. cls_flower is
>>>>extended to offload classid to hardware. The offloaded classid
>>>>is used direct matched packets to a traffic class on the device.
>>>>The approach here is similar to the tc 'prio' qdisc which uses
>>>>the classid for band selection. The ingress qdisc is called ffff:0,
>>>>so traffic classes are ffff:1 to ffff:8 (i40e has max of 8 TCs).
>>>
>>>
>>> NACK. This clearly looks like abuse of classid to something
>>> else. Classid is here to identify qdisc instance. However, you use it
>>> for hw tclass identification. This is mixing of apples and oranges.
>>>
>>> Why?
>>>
>>> Please don't try to abuse things! This is not nice.
>>
>>This isn't an abuse. This is reproducing in hardware what is already
>>the behavior for software. Isn't that how offloads are supposed to
>>work?
> 
> What is meaning of classid in HW? Classid is SW only identification of
> qdisc instances. No relation to HW instances = abuse.

Jiri I really don't see what the problem is.

As long as the driver does the right thing when changes are made to the
qdisc, it doesn't really matter what "key" they use to refer to it.

It could have just as easily used the qdisc pointer and then internally
use some IDR allocated ID to refer to it in the driver and hardware.

But that's such a waste, we have a unique handle already so why can't
the driver just use that?
