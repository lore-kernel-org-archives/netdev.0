From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH RFC 0/2] stmmac: stand alone platform drivers
Date: Tue, 12 May 2015 19:20:45 +0200
Message-ID: <CAGhQ9Vx0DQf-HcqEiohFLrBJPBe5qYjLgXiH3qGx85fAruh8UQ@mail.gmail.com>
References: <1431022765-30715-1-git-send-email-manabian@gmail.com>
	<5987007.lq0DjS0tE0@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"peppe.cavallaro" <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:32976 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932776AbbELRUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 13:20:47 -0400
Received: by lbbzk7 with SMTP id zk7so11246127lbb.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 10:20:45 -0700 (PDT)
In-Reply-To: <5987007.lq0DjS0tE0@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8 May 2015 at 15:30, Arnd Bergmann <arnd@arndb.de> wrote:
> On Thursday 07 May 2015 20:19:23 Joachim Eastwood wrote:
>> Hi Arnd,
>>
>> I ran into some issue using a separate platform driver[1] for lpc1850-dwmac.
>>
>> My dts files looks like this.
>> mac: ethernet@40010000 {
>>         compatible = "nxp,lpc1850-dwmac", "snps,dwmac-3.611", "snps,dwmac";
>>         ...
>> }
>>
>> On boot the generic driver in stmmac_platform.c would grab the
>> device, matching on one of generic compat strings and thus blocking
>> the lpc1850-dwmac driver.
>>
>> By changing the build order in the Makefile (see patch 1) I managed
>> to get it working, but I am not sure that is a good solution(?).
>
> Changing the link order in the Makefile is an acceptable solution
> for managing initialization order in general, but I think it won't
> work here, because if your driver is a loadable module, the base
> driver would always be attached first.

That is true.

The setup/configuration I am testing doesn't use modules though and
the only way I can get the lpc1850-dwmac driver to probe the device is
to link the generic driver last.

>> Another fix would be to remove the generic compat strings from the
>> match table in stmmac_platform but there are some dts-files that
>> only have these compat strings.
>> See abilis_tb10x.dtsi and exynos5440.dtsi.
>
> Yes, that has a high risk of causing regressions.
>
>> I could also remove the generic compat strings from my dts file but
>> I am not sure that is good solution either. If more glue is
>> converted this would then be need in those dts files also.
>
> I think it would work if you move the generic strings into a separate
> module that is not the one providing the base support. In that case,
> the kernel should first try to use the driver that matches the first
> compatible string. Can you try that?

I have now created a generic dt dwmac driver which contain all compat
strings that doesn't have any match data. As long as this driver is
linked last this works for my built-in drivers configuration. I am not
able to test using modules because of my very limited rootfs. This is
a Cortex-M system after all.

I also converted all the other DT dwmac drivers and the entire patch
set can be found on:
https://github.com/manabian/linux-lpc

After I have done some more cleanups and added proper commit messages
I will put them on netdev again.


regards,
Joachim Eastwood
