From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Mon, 30 Nov 2015 17:02:15 -0800
Message-ID: <CALx6S35_rXPsYUGcc+yrQX8K1dOcL4aWnmQsa-6X6xULo9BBbg@mail.gmail.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
	<1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
	<CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
	<20151129.222138.1582847465760563254.davem@davemloft.net>
	<CAEh+42ivCoBE-vAwWpHHmHYqcXzKP+ceZSvg2rEPh7Db3M1k6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:33480 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754964AbbLABCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 20:02:16 -0500
Received: by iouu10 with SMTP id u10so196759979iou.0
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 17:02:16 -0800 (PST)
In-Reply-To: <CAEh+42ivCoBE-vAwWpHHmHYqcXzKP+ceZSvg2rEPh7Db3M1k6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2015 at 4:25 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Sun, Nov 29, 2015 at 7:21 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Mon, 23 Nov 2015 13:53:44 -0800
>>
>>> The bad effect of this model is that it is encourages HW vendors to
>>> continue implement HW protocol specific support for encapsulations, we
>>> get so much more benefit if they implement protocol generic
>>> mechanisms.
>>
>> +1
>
> Regardless of what happens in the future, I think the main question is
> how this relates to the code that is currently present in the tree. We
> already have NDOs for VXLAN offloading, which is about as protocol
> specific as you can get. In my mind, this series is strictly an
> improvement to what is already there - it pulls all hardware
> offloading code out of the various protocol implementations and VXLAN
> out of the driver interface. That seems like a pretty nice cleanup to
> me.

Jesse,

I don't think VXLAN is a good role model here. Consider that Cisco now
is basically trying to obsolete VXLAN in favor of VXLAN-GPE. VXLAN-GPE
is not compatible with VXLAN, so in order to get the same HW offloads
talking VXLAN-GPE users will probably need to swap out their HW. If I
am misreading this situation let me know, but to me this doesn't sound
like a model the stack should endorse.

Tom
