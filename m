From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH 2/2] r8169: fix sleeping while holding spinlock.
Date: Tue, 9 Nov 2010 10:48:00 +1100
Message-ID: <AANLkTi=0v8pVoMH0msaUwUOM495ngRHeZ0ja04gVB7ni@mail.gmail.com>
References: <20101108232358.GB13720@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Daniel J Blueman <daniel.blueman@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46779 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557Ab0KHXsD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 18:48:03 -0500
Received: by fxm16 with SMTP id 16so4543621fxm.19
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 15:48:01 -0800 (PST)
In-Reply-To: <20101108232358.GB13720@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Was getting this error on boot "BUG: scheduling while atomic:
ethtool/1430/0x00000002" patch fixed them.

Acked-by: Andrew Hendry <andrew.hendry@gmail.com>

On Tue, Nov 9, 2010 at 10:23 AM, Francois Romieu <romieu@fr.zoreil.com>=
 wrote:
> As device_set_wakeup_enable can now sleep, move the call to outside
> the critical section.
>
> Signed-off-by: Daniel J Blueman <daniel.blueman@gmail.com>
> Acked-by: Rafael J. Wysocki <rjw@sisk.pl>
> ---
> =A0drivers/net/r8169.c | =A0 =A04 ++--
> =A01 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 3a0877e..4c4d169 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -846,10 +846,10 @@ static int rtl8169_set_wol(struct net_device *d=
ev, struct ethtool_wolinfo *wol)
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->features &=3D ~RTL_FEATURE_WOL;
> =A0 =A0 =A0 =A0__rtl8169_set_wol(tp, wol->wolopts);
> - =A0 =A0 =A0 device_set_wakeup_enable(&tp->pci_dev->dev, wol->wolopt=
s);
> -
> =A0 =A0 =A0 =A0spin_unlock_irq(&tp->lock);
>
> + =A0 =A0 =A0 device_set_wakeup_enable(&tp->pci_dev->dev, wol->wolopt=
s);
> +
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> --
> 1.7.2.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
