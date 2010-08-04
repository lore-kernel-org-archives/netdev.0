From: Eric Miao <eric.y.miao@gmail.com>
Subject: Re: [PATCH] net: add Fast Ethernet driver for PXA168.
Date: Wed, 4 Aug 2010 15:08:51 +0800
Message-ID: <AANLkTikqTLKX_F-PJGtChWc7SOjWJkO_3bNyNXcKZcb_@mail.gmail.com>
References: <20100804104750.GA9652@pe-dt013.marvell.com> <20100804065818.GI21121@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sachin Sanap <ssanap@marvell.com>, netdev@vger.kernel.org,
	akarkare@marvell.com, sarnaik@marvell.com, prakity@marvell.com,
	markb@marvell.com
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44101 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758395Ab0HDHJM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 03:09:12 -0400
Received: by wyb39 with SMTP id 39so5209321wyb.19
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 00:09:11 -0700 (PDT)
In-Reply-To: <20100804065818.GI21121@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 4, 2010 at 2:58 PM, Lennert Buytenhek
<buytenh@wantstofly.org> wrote:
> On Wed, Aug 04, 2010 at 04:17:50PM +0530, Sachin Sanap wrote:
>
>> This patch adds support for PXA168 Fast Ethernet on Aspenite
>> board.
>
> There's nothing Aspenite-specific in this patch (nor should there be)=
,
> so you can leave that part out.
>
>
>> Patch generated against Linux 2.6.35-rc5
>> commit cd5b8f8755a89a57fc8c408d284b8b613f090345
>
> This might be interesting to know but shouldn't be part of the commit
> message.
>
>
>> diff --git a/arch/arm/mach-mmp/include/mach/pxa168_eth.h b/arch/arm/=
mach-mmp/include/mach/pxa168_eth.h
>> new file mode 100644
>> index 0000000..abfd335
>> --- /dev/null
>> +++ b/arch/arm/mach-mmp/include/mach/pxa168_eth.h
>> @@ -0,0 +1,18 @@
>> +/*
>> + *pxa168 ethernet platform device data definition file.
>> + */
>> +#ifndef __LINUX_PXA168_ETH_H
>> +#define __LINUX_PXA168_ETH_H
>
> This should just be in include/linux, IMHO, as this unit isn't only u=
sed
> in the PXA168, for one.
>

Yep.

>
>> +struct pxa168_eth_platform_data {
>> + =C2=A0 =C2=A0 int =C2=A0 =C2=A0 port_number;
>> + =C2=A0 =C2=A0 u16 =C2=A0 =C2=A0 phy_addr;
>> +
>> + =C2=A0 =C2=A0 /* If speed is 0, then speed and duplex are autonego=
tiated. */
>> + =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 speed; =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0/* 0, SPEED_10, SPEED_100 */
>> + =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 duplex; =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 /* DUPLEX_HALF or DUPLEX_FULL */
>
> phylib treats these three (phy address, speed and duplex) as ints, is
> there any reason you need these to be of different types?
>
>
>> + =C2=A0 =C2=A0 int (*init)(void);
>
> What's this needed for? =C2=A0The name of this callback is entirely
> nondescriptive, there's no comment as to when it's called, etc.
>
>
>> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>> index ce2fcdd..5ebf287 100644
>> --- a/drivers/net/Kconfig
>> +++ b/drivers/net/Kconfig
>> @@ -927,6 +927,16 @@ config SMC91X
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 The module will be called smc91x. =C2=A0=
If you want to compile it as a
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 module, say M here and read <file:Docume=
ntation/kbuild/modules.txt>.
>>
>> +config PXA168_ETH
>> + =C2=A0 =C2=A0 tristate "Marvell pxa168 ethernet support"
>> + =C2=A0 =C2=A0 depends on MACH_ASPENITE
>
> You can have it depend on ARM or PXA168, but having it depend on supp=
ort
> for one specific board support file is almost certainly wrong.
>

depends on CPU_PXA168

probably makes more sense here.

And yeah we also found the driver to be very similar to mv643xx_eth
at that time, though not sure how much it resembles. So it would be
definitely good to have some comment why to make this a separate
driver, instead of reusing mv643xx_eth.
