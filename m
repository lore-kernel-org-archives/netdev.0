From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [net-next-2.6 PATCH 2/3] fs_enet: Add support for MPC512x to
	fs_enet driver
Date: Wed, 10 Feb 2010 07:28:14 -0700
Message-ID: <fa686aa41002100628x7ffc8fa9h3170f58387c5b67d@mail.gmail.com>
References: <4B5871F2.9090005@grandegger.com> <20100121.180311.228791894.davem@davemloft.net>
	<20100209152317.5303b1b3@wker> <20100209.121356.216640014.davem@davemloft.net>
	<4B72794A.9010805@grandegger.com> <4B728869.1090404@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, agust@denx.de,
	netdev@vger.kernel.org, dzu@denx.de, wd@denx.de, jcrigby@gmail.com,
	kosmo@semihalf.com, linuxppc-dev@ozlabs.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f224.google.com ([209.85.217.224]:62891 "EHLO
	mail-gx0-f224.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914Ab0BJO2g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 09:28:36 -0500
Received: by gxk24 with SMTP id 24so55030gxk.1
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 06:28:35 -0800 (PST)
In-Reply-To: <4B728869.1090404@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 10, 2010 at 3:20 AM, Wolfgang Grandegger <wg@grandegger.com=
> wrote:
> Wolfgang Grandegger wrote:
>> Hi David,
>>
>> David Miller wrote:
>>> From: Anatolij Gustschin <agust@denx.de>
>>> Date: Tue, 9 Feb 2010 15:23:17 +0100
>>>
>>>> In my understanding, in the ESP scsi driver the set of defines for
>>>> the register offsets is common for all chip drivers. The chip driv=
er
>>>> methods for register access translate the offsets because the
>>>> registers on some chips are at different intervals (4-byte, 1-byte=
,
>>>> 16-byte for mac_esp.c). But the register order is the same for
>>>> different chips.
>>>>
>>>> In our case non only the register order is not the same for 8xx
>>>> FEC and 5121 FEC, but there are also other differences, different
>>>> reserved areas between several registers, some registers are
>>>> available only on 8xx and some only on 5121.
>>> That only means you would need to use a table based register addres=
s
>>> translation scheme, rather than a simple calculation. =A0Something
>>> like:
>>>
>>> static unsigned int chip_xxx_table[] =3D
>>> {
>>> =A0 =A0 =A0[GENERIC_REG_FOO] =A0 =A0 =A0 =A0=3D CHIP_XXX_FOO,
>>> =A0 =A0 =A0...
>>> };
>>>
>>> static u32 chip_xxx_read_reg(struct chip *p, unsigned int reg)
>>> {
>>> =A0 =A0 =A0unsigned int reg_off =3D chip_xxx_table[reg];
>>>
>>> =A0 =A0 =A0return readl(p->regs + reg_off);
>>> }
>>>
>>> And this table can have special tokens in entries for
>>> registers which do not exist on a chip, so you can trap
>>> attempted access to them in these read/write handlers.
>>
>> Yes, that could be done, but to honest, I do not see any improvement=
 in
>> respect to the previous patch where the register offset were defined=
 via
>> pointers within a structure.
>>
>>> Please stop looking for excuses to fork this driver, a
>>> unified driver I think can be done cleanly.
>>
>> Other people suggested to fork the driver because it's getting too u=
gly.
>
> That said, I think there is consensus that it does not make sense, an=
d
> it's even not possible, to provide a kernel image which runs on both,
> the 8xx and the mpc512x. Therefore, there is also no need for sharing
> this driver at run time. Compile time selection would allow a more
> elegant and transparent implementation. Would that be an acceptable
> solution?

I'm okay with compile time selection.

g.
