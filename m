From: Tom Herbert <tom@herbertland.com>
Subject: Re: Checksum offload queries
Date: Wed, 9 Dec 2015 08:08:23 -0800
Message-ID: <CALx6S37Dw_reYPXd9_4wCTO+BMqwQrvfMfEWDD7XCToODmm=rg@mail.gmail.com>
References: <5665A848.9010001@solarflare.com>
	<20151207.143848.2158761076110518741.davem@davemloft.net>
	<5666EC4B.40800@solarflare.com>
	<CALx6S36aMvroE0mWz9+9EU+newrfkUqqFO+6T5YZVh_9xrMJLg@mail.gmail.com>
	<20151209015602.GB19097@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37729 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000AbbLIQIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 11:08:24 -0500
Received: by igcto18 with SMTP id to18so43575357igc.0
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 08:08:24 -0800 (PST)
In-Reply-To: <20151209015602.GB19097@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 8, 2015 at 5:56 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 12/08/15 at 09:04am, Tom Herbert wrote:
>> There are other reasons why CHECKSUM_COMPLETE is preferable:
>>
>> - CHECKSUM_COMPLETE  is more robust. We have no way to validate that
>> the device is actually correct in CHECKSUM_UNNECESSARY. For instance,
>> how do we know that there isn't some failure in the device where
>> everything is being marked as good even if it's not. With
>> CHECKSUM_COMPLETE it is the host that actually makes the decision of
>> whether the checksum is correct it is highly unlikely that failing
>> checksum calculation on the device won't be detected. HW failures and
>> bugs are real concern.
>> -  CHECKSUM_UNNECESSARY does not report bad checksums. There is a
>> csum_bad flag in the sk_buff that could be set if the driver detects a
>> bad checksum in the packet, but no drivers seem to be setting that
>> currently. So for any packets with bad checksums the stack will need
>> to compute the checksum itself, so this potentially becomes the basis
>> of a DDOS attack. CHECKSUM_COMPLETE does not have this problem, we get
>> the checksum of the packet rather the checksum is correct or not.
>
> If I understood Edward correctly, his proposal would be for the
> card to provide both, the csum as for CHECKSUM_COMPLETE plus the
> validation yes/no hint. It would be up to the kernel to decide
> whether to validate itself or trust the card.
>
> I'm all in favour CHECKSUM_COMPLETE as the only way to go but
> we should be aware that it depends on the penetration of RCO in
> hardware VTEPs.

Thomas, I don't understand what you are saying here. CHECKSUM_COMPLETE
is an interface for drivers providing the computed checksum of a
packet on receive, how is this dependent on any use case or any other
mechanisms?
