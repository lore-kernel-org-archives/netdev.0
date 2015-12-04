From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Fri, 4 Dec 2015 12:44:57 -0800
Message-ID: <CAEh+42jaG5nSqZfpRkphEBa_t2xuCOSknNvo=RdsLqcivK3dEg@mail.gmail.com>
References: <1449158374.11080.456996721.69F803D7@webmail.messagingengine.com>
 <CALx6S342OMLB6s7LcmnZP1rnYNUs345Dy1gjYX3JUKqqB_waPA@mail.gmail.com>
 <1449259145.6236.458303617.55CF2C4E@webmail.messagingengine.com>
 <20151204.150633.1744714566987717806.davem@davemloft.net> <1449260785.11089.458370265.3954BCFA@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>, linville@tuxdriver.com,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:48435 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756273AbbLDUpU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 15:45:20 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id F097820613
	for <netdev@vger.kernel.org>; Fri,  4 Dec 2015 20:45:18 +0000 (UTC)
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2CDC7205EB
	for <netdev@vger.kernel.org>; Fri,  4 Dec 2015 20:45:18 +0000 (UTC)
Received: by qgcc31 with SMTP id c31so98025919qgc.3
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 12:45:17 -0800 (PST)
In-Reply-To: <1449260785.11089.458370265.3954BCFA@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 4, 2015 at 12:26 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi Dave,
>
> On Fri, Dec 4, 2015, at 21:06, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Fri, 04 Dec 2015 20:59:05 +0100
>>
>> > Yes, I agree, I am totally with you here. If generic offloading can be
>> > realized by NICs I am totally with you that this should be the way to
>> > go. I don't see that coming in the next (small number of) years, so I
>> > don't see a reason to stop this patchset.
>>
>> If I just apply this and say "yeah ok", the message is completely lost
>> and your prediction about "small number of years" indeed will occur.
>>
>> However if I push back hard on this, as I will, then the message has
>> some chance of seeping back to the people designing these chips.
>>
>> So that's what I'm going to do, like it or not.
>>
>> Or can someone convince me that someone who understand this stuff
>> is telling the hardware guys to universally put 2's complement
>> checksums into the descriptors?
>>
>> Who is doing that at each and every prominent ethernet hardware
>> verndor?
>>
>> Who?
>>
>> If I get silence, or some vague non-specific response, then I'm going
>> to hold my ground and keep pushing back on this stuff.
>
> This is not only about 1's checksumming but also about TSO (and to some
> smaller degree about RSS, as I tried to explain): if we attach a geneve
> header in front of a skb we expect the hardware to recognize it and
> duplicate it while doing the hardware segmentation. The hardware can
> only do so if it is in knowledge of the specific port (in this case UDP
> port used for geneve) which is in use for this particular tunneling
> transport protocol. We currently cannot describe this in a generic way,
> thus this patchset. (Please correct me if I am wrong!)

This isn't really about TSO so much as receive side offloads. However,
the general point still stands.

Checksum is only one component and really the only one that has this
type of generalizable mathematical property. n-tuple offloads, LRO,
etc. are things that are currently supported by the stack and need
this type of support. And encryption, which people are already pushing
for, has the same issue. The fact is that there is no real plan to be
able to support these types of things in a way other than what is
being done in this patchset.

I do believe that there is genuine interest in working to find
solutions to these types of problems as John and et. al. have already
been doing. However, a real, fully general solution is not something
that exists as this point in time, as you can see from all of the
discussion in this thread.
