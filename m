From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v3 3/3] geneve: Remote Checksum Offload support
Date: Wed, 16 Dec 2015 08:41:57 -0800
Message-ID: <CALx6S37jRCwwZHDSVY6DOY3u9EUkHnQsupFa5zzx-KWk7pE5AA@mail.gmail.com>
References: <1449779866-3704097-1-git-send-email-tom@herbertland.com>
	<1449779866-3704097-4-git-send-email-tom@herbertland.com>
	<CAEh+42hCrCOqnPf2Sj5po6MjtJie=kL2QX4MmBqcAquJp4RUng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37169 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722AbbLPQl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 11:41:58 -0500
Received: by mail-ig0-f170.google.com with SMTP id to18so55778607igc.0
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 08:41:58 -0800 (PST)
In-Reply-To: <CAEh+42hCrCOqnPf2Sj5po6MjtJie=kL2QX4MmBqcAquJp4RUng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 10, 2015 at 1:17 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Thu, Dec 10, 2015 at 12:37 PM, Tom Herbert <tom@herbertland.com> wrote:
>> Add support for remote checksum offload in both the normal and GRO
>> paths. netlinks command are used to enable sending of the Remote
>> Checksum Data, and allow processing of it on receive.
>>
>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>
> Tom, can you please split this patch off and mark it as RFC or similar?
>
> I don't have any objections to implementing remote checksum offload
> for Geneve in general but I think that it's pretty clear that the
> format that you are using here is not the direction that the protocol
> is going to evolve. We don't need to fragment the protocol by applying
> this at this time.

The first two patches were accepted, you should have enough to
implement the remote checksum patches in the TLV format so you can
take it from here.

As for direction, I strongly suggest that you define some TLVs,
implement the TLV processing loop, and begin analyzing performance in
both HW and SW ASAP. As mentioned in the Geneve draft:

"The use of a variable length header and options in a protocol often
raises questions about whether it is truly efficiently implementable
in hardware."

I don't see that you've answered the question of rather TLVs can be
even be efficiently implemented in software much less hardware.
Without answering these questions I don't think we can claim the
protocol is viable or provides any benefit over VXLAN.

Tom
