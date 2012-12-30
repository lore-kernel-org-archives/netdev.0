From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH v2 1/1 net-next] NET: FEC: dynamtic check DMA desc buff
 type
Date: Sun, 30 Dec 2012 09:01:31 +0800
Message-ID: <CAHrpEqS42MNXF011sROJOxWE7N66Roy_Bb5TC+CM5keFMf6D+A@mail.gmail.com>
References: <1356676164-10910-1-git-send-email-Frank.Li@freescale.com>
 <20701.45196.361432.80622@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Frank Li <Frank.Li@freescale.com>, netdev@vger.kernel.org,
 s.hauer@pengutronix.de, shawn.guo@linaro.org, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: =?ISO-8859-1?Q?Lothar_Wa=DFmann?= <LW@karo-electronics.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20701.45196.361432.80622@ipc1.ka-ro>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

2012/12/28 Lothar Wa=DFmann <LW@karo-electronics.de>:
> Frank Li writes:
>> MX6 and mx28 support enhanced DMA descript buff to support 1588
>> ptp. But MX25, MX3x, MX5x can't support enhanced DMA descript buff.
>> Check fec type and choose correct DAM descript buff type.
>                                     ^^^
> s/DAM/DMA/
> s/descript/descriptor/g
>
> [...]
>> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet=
/freescale/fec.c
>> index 0704bca..290f91c 100644
>> --- a/drivers/net/ethernet/freescale/fec.c
>> +++ b/drivers/net/ethernet/freescale/fec.c
>> @@ -76,6 +76,8 @@
>>  #define FEC_QUIRK_USE_GASKET         (1 << 2)
>>  /* Controller has GBIT support */
>>  #define FEC_QUIRK_HAS_GBIT           (1 << 3)
>> +/* Controller has extend desc buffer */
>> +#define FEC_QUICK_HAS_BUFDESC_EX     (1 << 4)
>                ^^^^^
> As Sascha has already pointed out, this should be 'QUIRK' rather than
> 'QUICK' (like in the preceeding lines)!
>
>>  static struct platform_device_id fec_devtype[] =3D {
>>       {
>> @@ -93,7 +95,8 @@ static struct platform_device_id fec_devtype[] =3D {
>>               .driver_data =3D FEC_QUIRK_ENET_MAC | FEC_QUIRK_SWAP_FRAME,
>>       }, {
>>               .name =3D "imx6q-fec",
>> -             .driver_data =3D FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT,
>> +             .driver_data =3D FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
>> +                             FEC_QUICK_HAS_BUFDESC_EX,
>                                     ^^^^^
> same as above.
>
> [...]
>> @@ -1574,6 +1617,8 @@ fec_probe(struct platform_device *pdev)
>>       fep->pdev =3D pdev;
>>       fep->dev_id =3D dev_id++;
>>
>> +     fep->bufdesc_ex =3D 0;
>> +
>>       if (!fep->hwp) {
>>               ret =3D -ENOMEM;
>>               goto failed_ioremap;
>> @@ -1628,19 +1673,19 @@ fec_probe(struct platform_device *pdev)
>>               goto failed_clk;
>>       }
>>
>> -#ifdef CONFIG_FEC_PTP
>>       fep->clk_ptp =3D devm_clk_get(&pdev->dev, "ptp");
>> +     fep->bufdesc_ex =3D
>> +             pdev->id_entry->driver_data & FEC_QUICK_HAS_BUFDESC_EX;
>                                                   ^^^^^
> same as above.

Okay, I will fix it after new year holiday.

>
>
> Lothar Wa=DFmann
> --
> ___________________________________________________________
>
> Ka-Ro electronics GmbH | Pascalstra=DFe 22 | D - 52076 Aachen
> Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
> Gesch=E4ftsf=FChrer: Matthias Kaussen
> Handelsregistereintrag: Amtsgericht Aachen, HRB 4996
>
> www.karo-electronics.de | info@karo-electronics.de
> ___________________________________________________________
