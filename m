From: Manuel Lauss <manuel.lauss@googlemail.com>
Subject: Re: [PATCH 1/3] au1000_eth: use write accessors
Date: Wed, 29 Jul 2009 09:51:57 +0200
Message-ID: <f861ec6f0907290051v48ce0561tb74a84341485de74@mail.gmail.com>
References: <200907282306.27738.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f221.google.com ([209.85.218.221]:44223 "EHLO
	mail-bw0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbZG2Hv6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 03:51:58 -0400
Received: by bwz21 with SMTP id 21so520432bwz.37
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 00:51:57 -0700 (PDT)
In-Reply-To: <200907282306.27738.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Tue, Jul 28, 2009 at 11:06 PM, Florian Fainelli<florian@openwrt.org>=
 wrote:
> Hi David,
>
> The next 3 patches apply to on top of the patch series that I
> sent earlier converting au1000_eth to become a platform_driver.
> Thanks !
> --
> From: Florian Fainelli <florian@openwrt.org>
> This patch replaces all occurences of *aup->enable =3D val
> by writel(val, &aup->enable)
>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> ---
> diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
> index 57cc4f6..1f724da 100644
> --- a/drivers/net/au1000_eth.c
> +++ b/drivers/net/au1000_eth.c
> @@ -155,10 +155,10 @@ static void enable_mac(struct net_device *dev, =
int force_reset)
> =A0 =A0 =A0 =A0spin_lock_irqsave(&aup->lock, flags);
>
> =A0 =A0 =A0 =A0if(force_reset || (!aup->mac_enabled)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 *aup->enable =3D MAC_EN_CLOCK_ENABLE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 writel(MAC_EN_CLOCK_ENABLE, &aup->enabl=
e);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0au_sync_delay(2);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 *aup->enable =3D (MAC_EN_RESET0 | MAC_E=
N_RESET1 | MAC_EN_RESET2
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | MAC_E=
N_CLOCK_ENABLE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 writel((MAC_EN_RESET0 | MAC_EN_RESET1 |=
 MAC_EN_RESET2
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | MAC_EN_CLOCK_ENABLE),=
 &aup->enable);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0au_sync_delay(2);

While you're at it, please also replace all "au_sync_delay()" with
mmiowb() + msleep()

Thanks!
      Manuel Lauss
