From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] drivers/ptp/Kconfig: add "depends on HAS_IOMEM" for 'PTP_1588_CLOCK_PCH'
Date: Mon, 1 Jul 2013 09:32:04 +0200
Message-ID: <CAMuHMdXnO8-9riLcFLQfMoWJRgy7gtQJdKkHZNR0D5eaM4=oxQ@mail.gmail.com>
References: <51CB8CB7.6010006@asianux.com>
	<20130628.212311.1348427834856668120.davem@davemloft.net>
	<51D0DCB5.5060106@asianux.com>
	<51D11661.7040604@nod.at>
	<51D11D14.8000706@asianux.com>
	<51D122F0.1000204@nod.at>
	<51D12545.4000108@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Weinberger <richard@nod.at>,
	David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:63131 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140Ab3GAHcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 03:32:05 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr13so4488406pbb.6
        for <netdev@vger.kernel.org>; Mon, 01 Jul 2013 00:32:04 -0700 (PDT)
In-Reply-To: <51D12545.4000108@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 1, 2013 at 8:44 AM, Chen Gang <gang.chen@asianux.com> wrote:
> On 07/01/2013 02:34 PM, Richard Weinberger wrote:
>>> config COMPILE_TEST
>>> >         bool "Compile also drivers which will not load"
>>> >         default n
>>> >         help
>>> >           Some drivers can be compiled on a different platform than they are
>>> >           intended to be run on. Despite they cannot be loaded there (or even
>>> >           when they load they cannot be used due to missing HW support),
>>> >           developers still, opposing to distributors, might want to build such
>>> >           drivers to compile-test them.
>>> >
>>> >           If you are a developer and want to build everything available, say Y
>>> >           here. If you are a user/distributor, say N here to exclude useless
>>> >           drivers to be distributed.
>>> >
>>> > I guess, 'COMPILE_TEST' is really useful for UML.
>> No.
>>
>> We have explained you more than once what the deal and why UML does not
>> have ioremap() and friends.
>
> This time, it is not for UML, it is for 'COMPILE_TEST': the
> 'asm-generic' whether need consider it.

COMPILE_TEST is only meant to be used as a dependency in Kconfig files,
to make drivers that cannot work due to missing hardware invisible when
configuring your kernel.

There should be no #ifdefs in actual code that check for (the lack of)
CONFIG_COMPILE_TEST.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
