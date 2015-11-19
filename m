From: Tom Herbert <tom@herbertland.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 15:24:26 -0800
Message-ID: <CALx6S34_ZHrJg5rtt-72LoHUdKNcBc=7qNNrAxnBAKVMjo7LZQ@mail.gmail.com>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
	<20151119.005318.838757439536205791.davem@davemloft.net>
	<CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
	<20151119.104811.1447518072450380661.davem@davemloft.net>
	<1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
	<1447952902.2049284.444501617.7C422D07@webmail.messagingengine.com>
	<CALx6S379hXL=QEBF-HmOvPr3K55tS87HV=wKOySro1A0ogmWcQ@mail.gmail.com>
	<CAKD1Yr1ji7AP-YKJ5kG8xYhgksNbXKKKcLoQPRsEtN020Gb_0g@mail.gmail.com>
	<1447972681.3063104.444798817.76BFD7A6@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lorenzo Colitti <lorenzo@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34869 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934042AbbKSXY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 18:24:28 -0500
Received: by ioc74 with SMTP id 74so106285454ioc.2
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 15:24:27 -0800 (PST)
In-Reply-To: <1447972681.3063104.444798817.76BFD7A6@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015 at 2:38 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
>
> On Thu, Nov 19, 2015, at 23:33, Lorenzo Colitti wrote:
>> On Fri, Nov 20, 2015 at 2:38 AM, Tom Herbert <tom@herbertland.com> wrote:
>> >> I actually don't have an issue with killing from user space that much. I
>> >> still recommend (and actually have started to look at it today) to add a
>> >> new substate for TCP TIMEWAIT and don't have any issue if we block the
>> >> socket for 60 seconds and send RSTs to all incoming data. This way we
>> >> can solve the problem Florian indicated as well as this problem. Users
>> >> can happily kill TCP connections then.
>> >>
>> > Neither do I have a problem with killing connections from userspace,
>> > but we do have to acknowledge that this is a powerful and invasive
>> > mechanism. I suggest:
>> >
>> > 1) We need transparency. If a third party kills a TCP connection then
>> > the application should be informed of specifically that. This seems
>> > easy enough to just pick an appropriate error number as I suggested.
>>
>> I'm not wedded to ETIMEDOUT. If it means we can get this code
>> upstream, then we can likely do the userspace work that is needed to
>> ensure that applications respond correctly. Mot
>>
>> > 2) We need constraints. This feature seems to be specific to a very
>> > narrow use case. It is not at all clear to me if there are any
>> > legitimate uses cases beyond Android, enabling this by default in the
>> > stack creates a non-zero amount of risk and liability for abuse. It
>> > seems like this should be an opt-in sort of feature, with a kernel
>> > CONFIG or maybe opt-in per socket.
>>
>> I am perfectly happy for this to be behind a config option.
>
> Why? If it is an administrator only option it does not make sense to
> hide it behind a sysctl. Applications using this interface could also
> easily change the sysctl because they probably have the same privileges.
> A Kconfig option seems to be not useful to me either.
>

A sysctl is obviously useless, but Kconfig option is good. There is no
way I want this option enabled in my data center without any
demonstrated need for it. History has shown many times, that once we
allow options like this to be enabled in the kernel, they will
inevitably be used often without our (kernel experts') knowledge or
supervision. In too many cases this blows up in our faces (there has
been at least one outage @FB caused by someone inadvertently
exercising an otherwise obscure kernel feature).

Tom
