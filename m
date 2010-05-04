From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH] net/gianfar: drop recycled skbs on MTU change
Date: Tue, 4 May 2010 08:29:06 -0700
Message-ID: <o2g2acbd3e41005040829rc5bf7e0dwee8419b2b65e5468@mail.gmail.com>
References: <20100503151745.GA17997@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:48332 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933044Ab0EDP3H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 11:29:07 -0400
Received: by wwg30 with SMTP id 30so121785wwg.19
        for <netdev@vger.kernel.org>; Tue, 04 May 2010 08:29:06 -0700 (PDT)
In-Reply-To: <20100503151745.GA17997@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 3, 2010 at 8:17 AM, Sebastian Andrzej Siewior
<sebastian@breakpoint.cc> wrote:
> From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
>
> The size for skb which is added to the recycled list is using the
> current descriptor size which is current MTU. gfar_new_skb() is also
> using this size. So after changing or alteast increasing the MTU all
> recycled skbs should be dropped.
>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
> I'm not 100% sure but it looks like it is wrong.
>
> =A0drivers/net/gianfar.c | =A0 =A04 +++-
> =A01 files changed, 3 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index 5267c27..9093106 100644
> --- a/drivers/net/gianfar.c
> +++ b/drivers/net/gianfar.c
> @@ -2287,8 +2287,10 @@ static int gfar_change_mtu(struct net_device *=
dev, int new_mtu)
>
> =A0 =A0 =A0 =A0/* Only stop and start the controller if it isn't alre=
ady
> =A0 =A0 =A0 =A0 * stopped, and we changed something */
> - =A0 =A0 =A0 if ((oldsize !=3D tempsize) && (dev->flags & IFF_UP))
> + =A0 =A0 =A0 if ((oldsize !=3D tempsize) && (dev->flags & IFF_UP)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stop_gfar(dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_queue_purge(&priv->rx_recycle);
> + =A0 =A0 =A0 }


I think we should probably do this in free_skb_resources.  And remove
the call from gfar_close().

Andy
