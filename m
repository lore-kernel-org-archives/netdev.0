From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 09:43:18 -0800
Message-ID: <CALx6S36qHkUhz5VN+xvsMhszTQnCUUhQ+Doja86wLGWJEe_u_A@mail.gmail.com>
References: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
	<20151123.145433.1554000376541433305.davem@davemloft.net>
	<20151124152744.GB20972@breakpoint.cc>
	<20151124.105537.185897620062606312.davem@davemloft.net>
	<20151124162515.GA22266@breakpoint.cc>
	<CALx6S35uHQS1n7GYATZ-3UwLFhdiShdVzTBzEgdkKsQrmdpXZw@mail.gmail.com>
	<20151124171650.GA23215@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>, davejwatson@fb.com,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35666 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754647AbbKXRnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 12:43:18 -0500
Received: by ioc74 with SMTP id 74so27883378ioc.2
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 09:43:18 -0800 (PST)
In-Reply-To: <20151124171650.GA23215@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2015 at 9:16 AM, Florian Westphal <fw@strlen.de> wrote:
> Tom Herbert <tom@herbertland.com> wrote:
>> No one is being forced to use any of this.
>
> Right.  But it will need to be maintained.
> Lets ignore ktls for the time being and focus on KCM.
>
> I'm currently trying to figure out how memory handling in KCM
> is supposed to work.
>
> say we have following record framing:
>
> struct record {
>         u32 len;
>         char data[];
> };
>
> And I have a epbf filter that returns record->len within KCM.
> Now this program says 'length 128mbyte' (or whatever).
>
> If this was userspace, things are simple, userspace can either
> decide to hang up or start to read this in chunks as data arrives.
>
> AFAICS, with KCM, the kernel now has to keep 128mb of allocated
> memory around, rmem limits are ignored.
>
> Is that correct?  What if next record claims 4g in size?
> I don't really see how we can make any guarantees wrt.
> kernel stability...
>
> Am I missing something?

Message size limits can be enforced in BPF or we could add a limit
enforced by KCM. For instance, the message size limit in http/2 is
16M. If it's needed, it wouldn't be much trouble to add a streaming
interface for large messages.

>
> Thanks,
> Florian
