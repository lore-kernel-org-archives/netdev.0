From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 09:00:41 -0800
Message-ID: <CALx6S35uHQS1n7GYATZ-3UwLFhdiShdVzTBzEgdkKsQrmdpXZw@mail.gmail.com>
References: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
	<20151123.145433.1554000376541433305.davem@davemloft.net>
	<20151124152744.GB20972@breakpoint.cc>
	<20151124.105537.185897620062606312.davem@davemloft.net>
	<20151124162515.GA22266@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>, davejwatson@fb.com,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36219 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013AbbKXRAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 12:00:42 -0500
Received: by iofh3 with SMTP id h3so26581258iof.3
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 09:00:41 -0800 (PST)
In-Reply-To: <20151124162515.GA22266@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2015 at 8:25 AM, Florian Westphal <fw@strlen.de> wrote:
> David Miller <davem@davemloft.net> wrote:
>> From: Florian Westphal <fw@strlen.de>
>> Date: Tue, 24 Nov 2015 16:27:44 +0100
>>
>> > Aside from Hannes comment -- KCM seems to be tied to the TLS work, i.e.
>> > I have the impression that KCM without ability to do TLS in the kernel
>> > is pretty much useless for whatever use case Tom has in mind.
>>
>> I do not get this impression at all.
>>
>> Tom's design document in the final patch looks legitimately what the
>> core use case is.
>
> You mean
> https://patchwork.ozlabs.org/patch/547054/ ?
>
> Its a well-written document, but I don't see how moving the burden of
> locking a single logical tcp connection (to prevent threads from
> reading a partial record) from userspace to kernel is an improvement.
>
> If you really have 100 threads and must use a single tcp connection
> to multiplex some arbitrarily complex record-format in atomic fashion,
> then your requirements suck.
>
Well, this is the sort of thing that multi threaded applications do.

> Now, arguably, maybe the requirements of Toms use case are restricted
> /cannot be avoided.
>
> But that still begs the question: Why should mainline care?
>
I have no idea. I guess it's the same reason that mainline would care
about RDS, iSCSI, FCOE, RMDA, or anything in that nature. No one is
being forced to use any of this.

> Once its in, next step will be 'my single tcp connection that I use
> for multiplexing via KCM now has requirement to use TLS'.
>
> How far are you willing to take the KCM concept?

Obviously we are looking forward TLS+KCM. But it does open up a bunch
of other possibilities.
