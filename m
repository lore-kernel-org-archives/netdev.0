From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Mon, 30 Nov 2015 17:28:10 -0800
Message-ID: <CAEh+42gvn=cjZ4E3nACR7=-_a4iFS7OwEsSb+SQGme2k19kVAA@mail.gmail.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
 <1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
 <CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
 <20151129.222138.1582847465760563254.davem@davemloft.net> <CAEh+42ivCoBE-vAwWpHHmHYqcXzKP+ceZSvg2rEPh7Db3M1k6Q@mail.gmail.com>
 <CALx6S35_rXPsYUGcc+yrQX8K1dOcL4aWnmQsa-6X6xULo9BBbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:48449 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbbLAB2d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2015 20:28:33 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 095622066F
	for <netdev@vger.kernel.org>; Tue,  1 Dec 2015 01:28:32 +0000 (UTC)
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 91E1D20663
	for <netdev@vger.kernel.org>; Tue,  1 Dec 2015 01:28:30 +0000 (UTC)
Received: by qkfo3 with SMTP id o3so66764318qkf.1
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 17:28:29 -0800 (PST)
In-Reply-To: <CALx6S35_rXPsYUGcc+yrQX8K1dOcL4aWnmQsa-6X6xULo9BBbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2015 at 5:02 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, Nov 30, 2015 at 4:25 PM, Jesse Gross <jesse@kernel.org> wrote:
>> On Sun, Nov 29, 2015 at 7:21 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Tom Herbert <tom@herbertland.com>
>>> Date: Mon, 23 Nov 2015 13:53:44 -0800
>>>
>>>> The bad effect of this model is that it is encourages HW vendors to
>>>> continue implement HW protocol specific support for encapsulations, we
>>>> get so much more benefit if they implement protocol generic
>>>> mechanisms.
>>>
>>> +1
>>
>> Regardless of what happens in the future, I think the main question is
>> how this relates to the code that is currently present in the tree. We
>> already have NDOs for VXLAN offloading, which is about as protocol
>> specific as you can get. In my mind, this series is strictly an
>> improvement to what is already there - it pulls all hardware
>> offloading code out of the various protocol implementations and VXLAN
>> out of the driver interface. That seems like a pretty nice cleanup to
>> me.
>
> Jesse,
>
> I don't think VXLAN is a good role model here. Consider that Cisco now
> is basically trying to obsolete VXLAN in favor of VXLAN-GPE. VXLAN-GPE
> is not compatible with VXLAN, so in order to get the same HW offloads
> talking VXLAN-GPE users will probably need to swap out their HW. If I
> am misreading this situation let me know, but to me this doesn't sound
> like a model the stack should endorse.

The point that I was trying to make is that we already have VXLAN
offloading in the stack and it exists there today. The way that it is
implemented is about as protocol specific as you can get - protocols
need to know about offloads and drivers need to know about protocols.
I would like to find a way to at least make the code cleaner while we
wait for hardware to evolve.

Based on what we can do today, I see only two real choices: do some
refactoring to clean up the stack a bit or remove the existing VXLAN
offloading altogether. I think this series is trying to do the former
and the result is that the stack is cleaner after than before. That
seems like a good thing.
