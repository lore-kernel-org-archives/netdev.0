From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Fri, 14 Jan 2011 14:35:09 +0800
Message-ID: <AANLkTinQaqYN3Jo=N3W3a_9PYKPMbmvJU+_UjoajXnP9@mail.gmail.com>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com> <1294933197.4114.85.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294933197.4114.85.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Joe,

On Thu, Jan 13, 2011 at 11:39 PM, Joe Perches <joe@perches.com> wrote:
> On Thu, 2011-01-13 at 19:49 +0800, Po-Yu Chuang wrote:
>> From: Po-Yu Chuang <ratbert@faraday-tech.com>
>>
>> FTMAC100 Ethernet Media Access Controller supports 10/100 Mbps and
>> MII. =C2=A0This driver has been working on some ARM/NDS32 SoC includ=
ing
>> Faraday A320 and Andes AG101.
>
> A couple of trivial comments not already mentioned by others.
>
>> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> []
>> @@ -2014,6 +2014,15 @@ config BCM63XX_ENET
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 This driver supports the ethernet MACs i=
n the Broadcom 63xx
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 MIPS chipset family (BCM63XX).
>>
>> +config FTMAC100
>> + =C2=A0 =C2=A0 tristate "Faraday FTMAC100 10/100 Ethernet support"
>> + =C2=A0 =C2=A0 depends on ARM
>> + =C2=A0 =C2=A0 select MII
>> + =C2=A0 =C2=A0 help
>> + =C2=A0 =C2=A0 =C2=A0 This driver supports the FTMAC100 Ethernet co=
ntroller from
>> + =C2=A0 =C2=A0 =C2=A0 Faraday. It is used on Faraday A320, Andes AG=
101, AG101P
>> + =C2=A0 =C2=A0 =C2=A0 and some other ARM/NDS32 SoC's.
>> +
>
> ARM specific net drivers are for now in drivers/net/arm/
> Perhaps it's better to locate these files there?

This controller is used by not only ARM-base platforms, but also
NDS32-base ones.
NDS32 is an ISA designed by Andes tech. Although it is not yet in the m=
ainline,
they plan to push their stuff to mainline and are working on that.

So... I don't know if it is better to put my driver to driver/net/arm/.

Should I leave my driver at driver/net/ or put it in drvier/net/arm/
and let Andes tech guys
move it out of driver/net/arm/ when they use it later?

>> + =C2=A0 =C2=A0 if (unlikely(ftmac100_rxdes_rx_error(rxdes))) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (printk_ratelimit())
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 dev_info(dev, "rx err\n");
>
> There are many printk_ratelimit() tests.
>
> It's better to use net_ratelimit() or a local ratelimit_state
> so there's less possible suppression of other subsystem
> messages.

OK, fixed.


Thanks a lot for your absolutely non-trivial review. :-)
I'll submit a new version ASAP.

Thanks,
Po-Yu  Chuang
