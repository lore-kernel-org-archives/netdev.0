From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: Re: [PATCH V2] Add platform driver support to the CS890x driver
Date: Mon, 7 Nov 2011 13:14:14 +0100
Message-ID: <CAGzjT4eRSszCcxkPK-GBpBp9CTQ1BwYGQQD-n__ogjR8Z+pfwg@mail.gmail.com>
References: <20110913074626.GM28624@pengutronix.de>
	<1317148076-14931-1-git-send-email-jaccon.bastiaansen@gmail.com>
	<CAGzjT4eKJCf36_n-W-XpiFUymUZj=tVzXYp2DNJFXb-Wjz6RVA@mail.gmail.com>
	<20111103080615.GD16886@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Uwe_Kleine=2DK=F6nig?=
	<u.kleine-koenig@pengutronix.de>, kernel@pengutronix.de
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:46871 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753663Ab1KGMOQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 07:14:16 -0500
Received: by ggnb2 with SMTP id b2so5196841ggn.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 04:14:15 -0800 (PST)
In-Reply-To: <20111103080615.GD16886@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sascha,

I will do this. Since I'm on holiday the rest of the week, it will
take some time before I can post the new patches.

Regards,
  Jaccon

2011/11/3 Sascha Hauer <s.hauer@pengutronix.de>:
> Hi Jaccon,
>
> On Sun, Oct 09, 2011 at 10:51:23PM +0200, Jaccon Bastiaansen wrote:
>> Hello,
>>
>> This patch hasn't been sent to the netdev mailing list before, sorry=
 for that.
>
> I appreciate what you are trying to do. The cs89x0 is still not dead =
and
> it's quite annoying that we do not have proper platform device driver
> support for it. Unfortunately your patch was ignored by the important
> people, so can you respin it? You should create a proper series from =
it
> with one patch for the driver and one patch per board. This helps to
> increase your visibility and also you can set the individual board
> maintainers on Cc for their board. Please also Cc
> netdev@vger.kernel.org and the arm linux kernel mailing list.
> Your patch also contains some cleanups like the removal of the unused
> QQ2440. You should create a seperate patch for this, then it will be
> easier to review (and also people love to read 'cleanup' in a patch
> subject ;)
>
> Your mailer turns tabs into spaces, you should fix this before
> resending.
>
> Some more comments inline.
>
>
>>
>> +static struct resource ixdp2x01_cs8900_resources[] =3D {
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .start =A0=3D (u32)IXDP2X01_CS8900_VIR=
T_BASE,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .end =A0 =A0=3D (u32)IXDP2X01_CS8900_V=
IRT_BASE + 0x1000 - 1,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .flags =A0=3D IORESOURCE_MEM,
>> + =A0 =A0 =A0 },
>
> This is wrong. resources are about physical addresses, not virtual. Y=
ou
> have to ioremap them in the driver.
>
>> diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
>> index 537a4b2..b7fb3bc 100644
>> --- a/drivers/net/cs89x0.c
>> +++ b/drivers/net/cs89x0.c
>> @@ -12,6 +12,14 @@
>> =A0 =A0 =A0 =A0 The author may be reached at nelson@crynwr.com, Cryn=
wr
>> =A0 =A0 =A0 =A0 Software, 521 Pleasant Valley Rd., Potsdam, NY 13676
>>
>> +Sources
>> +
>> + =A0 =A0 =A0 Crynwr packet driver epktisa.
>> +
>> + =A0 =A0 =A0 Crystal Semiconductor data sheets.
>> +
>> +
>> +
>
> This seems unrelated to this patch. Please drop.
>
>> =A0 Changelog:
>>
>> =A0 Mike Cruse =A0 =A0 =A0 =A0: mcruse@cti-ltd.com
>> @@ -98,39 +106,14 @@
>> =A0 Domenico Andreoli : cavokz@gmail.com
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 : QQ2440 platform support
>>
>> + =A0Jaccon Bastiaansen: jaccon.bastiaansen@gmail.com
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 : added platform driver suppor=
t
>
> The history in git is enough (and even better) than the changelog in =
the
> file headers. Please drop this.
>
>> +
>> +#ifdef CONFIG_CS89x0_PLATFORM
>> +static int cs89x0_platform_probe(struct platform_device *pdev)
>> +{
>> + =A0 =A0 =A0 struct net_device *dev =3D alloc_etherdev(sizeof(struc=
t net_local));
>> + =A0 =A0 =A0 struct resource *mem_res;
>> + =A0 =A0 =A0 struct resource *irq_res;
>> + =A0 =A0 =A0 int err;
>> +
>> + =A0 =A0 =A0 if (!dev)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>> +
>> + =A0 =A0 =A0 mem_res =3D platform_get_resource(pdev, IORESOURCE_MEM=
, 0);
>> + =A0 =A0 =A0 irq_res =3D platform_get_resource(pdev, IORESOURCE_IRQ=
, 0);
>> + =A0 =A0 =A0 if (mem_res =3D=3D NULL || irq_res =3D=3D NULL) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_warning("memory and/or interrupt re=
source missing.\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENOENT;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 cs8900_irq_map[0] =3D irq_res->start;
>
> This limits the driver to a single instance. I think this is ok for n=
ow
> as an intermediate step, but you should check this and bail out with
> -EBUSY if a second instance is registered.
>
>> + =A0 =A0 =A0 err =3D cs89x0_probe1(dev, mem_res->start, 0);
>> + =A0 =A0 =A0 if (err) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_warning("no cs8900 or cs8920 detect=
ed.\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 platform_set_drvdata(pdev, dev);
>> + =A0 =A0 =A0 return 0;
>> +out:
>> + =A0 =A0 =A0 free_netdev(dev);
>> + =A0 =A0 =A0 return err;
>> +}
>
> Sascha
>
> --
> Pengutronix e.K. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
| =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |
> Industrial Linux Solutions =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | http://w=
ww.pengutronix.de/ =A0|
> Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0=
 =A0 =A0|
> Amtsgericht Hildesheim, HRA 2686 =A0 =A0 =A0 =A0 =A0 | Fax: =A0 +49-5=
121-206917-5555 |
>
