From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/ptp/Kconfig: add "depends on HAS_IOMEM" for 'PTP_1588_CLOCK_PCH'
Date: Mon, 01 Jul 2013 15:47:42 +0800
Message-ID: <51D1341E.6090908@asianux.com>
References: <51CB8CB7.6010006@asianux.com> <20130628.212311.1348427834856668120.davem@davemloft.net> <51D0DCB5.5060106@asianux.com> <51D11661.7040604@nod.at> <51D11D14.8000706@asianux.com> <51D122F0.1000204@nod.at> <51D12545.4000108@asianux.com> <CAMuHMdXnO8-9riLcFLQfMoWJRgy7gtQJdKkHZNR0D5eaM4=oxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Richard Weinberger <richard@nod.at>,
	David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:25495 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752969Ab3GAHse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 03:48:34 -0400
In-Reply-To: <CAMuHMdXnO8-9riLcFLQfMoWJRgy7gtQJdKkHZNR0D5eaM4=oxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2013 03:32 PM, Geert Uytterhoeven wrote:
> On Mon, Jul 1, 2013 at 8:44 AM, Chen Gang <gang.chen@asianux.com> wrote:
>> > On 07/01/2013 02:34 PM, Richard Weinberger wrote:
>>>> >>> config COMPILE_TEST
>>>>> >>> >         bool "Compile also drivers which will not load"
>>>>> >>> >         default n
>>>>> >>> >         help
>>>>> >>> >           Some drivers can be compiled on a different platform than they are
>>>>> >>> >           intended to be run on. Despite they cannot be loaded there (or even
>>>>> >>> >           when they load they cannot be used due to missing HW support),
>>>>> >>> >           developers still, opposing to distributors, might want to build such
>>>>> >>> >           drivers to compile-test them.
>>>>> >>> >
>>>>> >>> >           If you are a developer and want to build everything available, say Y
>>>>> >>> >           here. If you are a user/distributor, say N here to exclude useless
>>>>> >>> >           drivers to be distributed.
>>>>> >>> >
>>>>> >>> > I guess, 'COMPILE_TEST' is really useful for UML.
>>> >> No.
>>> >>
>>> >> We have explained you more than once what the deal and why UML does not
>>> >> have ioremap() and friends.
>> >
>> > This time, it is not for UML, it is for 'COMPILE_TEST': the
>> > 'asm-generic' whether need consider it.
> COMPILE_TEST is only meant to be used as a dependency in Kconfig files,
> to make drivers that cannot work due to missing hardware invisible when
> configuring your kernel.
> 

Why "Despite they cannot be loaded there (or even when they load they
cannot be used due to missing HW support)" ?

> There should be no #ifdefs in actual code that check for (the lack of)
> CONFIG_COMPILE_TEST.

In ideal world, it should be no #ifdefs for all "CONFIG_*" in 'normal code'.

But "asm-generic" are not belong to 'normal code', it is one of the main
place to process "CONFIG_*".

If the platforms need support 'COMPILE_TEST', the asm-generic is the
main place for implementing it.


So I think our focus is on "whether the platforms guys need support
'COMPILE_TEST" for modules guys".


Thanks
-- 
Chen Gang
