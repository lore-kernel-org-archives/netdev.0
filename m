From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: What's the expected path to recover from a PHY_HALTED transition?
Date: Mon, 16 Nov 2015 12:11:11 -0800
Message-ID: <564A385F.5090900@gmail.com>
References: <CAJ-Vmon_s0o7G84CBOb_V5Y-D-3TMNDq7AOhr9fdiOmxYaFBZg@mail.gmail.com>	<564A331E.6090603@gmail.com> <CAJ-Vmo=rgT1e3pPQHffjmRoRmHsQrmfQdSTRHqqnNGeLGRZZHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Adrian Chadd <adrian@freebsd.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:32890 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbbKPUML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 15:12:11 -0500
Received: by pabfh17 with SMTP id fh17so188076174pab.0
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 12:12:10 -0800 (PST)
In-Reply-To: <CAJ-Vmo=rgT1e3pPQHffjmRoRmHsQrmfQdSTRHqqnNGeLGRZZHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/11/15 12:05, Adrian Chadd wrote:
> On 16 November 2015 at 11:48, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 16/11/15 11:29, Adrian Chadd wrote:
>>> hi,
>>>
>>> I'm debugging an issue on the Broadcom parts (using unimac-mdio.c as
>>> the mdio bus) where i occasionally see MDIO bus read failures, which
>>> causes phy.c to transition the PHY to PHY_HALTED. It stays in this
>>> state until the link is bounced.
>>
>> There is a known problem with some Broadcom PHYs where the first MDIO
>> read may fail, and this can actually show up randomly in time, not just
>> the first read and that caused the PHY library to enter PHY_HALTED.
>> Which part are you seeing this? unimac-mdio.c has a reset hook just for
>> that cases.
> 
> It's the broadcom BCM7444.
> 
> The failure is -EIO from the unimac-mdio read method, which only
> happens when the hardware returns MDIO_READ_FAIL.
> 
>>> So, what's the expectation to handle this and recover from it? is
>>> there some userland piece monitoring things that I'm missing?
>>
>> There is not much you can do typically, but ignore or retry the read, or
>> workaround it if you can, like what bcm7xxx.c does.
> 
> What's the reset hack in bcm7xxx.c ? I don't see anything obvious.

That part:

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/drivers/net/phy/bcm7xxx.c#n175

> 
> (I'm currently stuck on 3.14.13-1.2 from broadcom's stb tree.)

That would explain it, the workaround mentioned above only made it in
3.14-1.8, and there are more releases available to you now, we should
probably talk off line about this downstream kernel.
-- 
Florian
