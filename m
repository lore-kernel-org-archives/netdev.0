From: Laurent Riffard <laurent.riffard@free.fr>
Subject: Re: 2.6.18-rc1-mm1 inconsistent lock state in netpoll_send_skb
Date: Mon, 10 Jul 2006 21:06:10 +0200
Message-ID: <44B2A522.2080703@free.fr>
References: <20060709021106.9310d4d1.akpm@osdl.org>	 <44B17735.4060006@free.fr> <1152520823.4874.0.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>,
	Kernel development list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g19.free.fr ([212.27.42.28]:50877 "EHLO smtp2-g19.free.fr")
	by vger.kernel.org with ESMTP id S1422775AbWGJTFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 15:05:55 -0400
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1152520823.4874.0.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Le 10.07.2006 10:40, Arjan van de Ven a =E9crit :
> On Sun, 2006-07-09 at 23:37 +0200, Laurent Riffard wrote:
>> ei_start_xmit
>=20
> please try this patch
>=20
> ---
>  drivers/net/8390.c |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
>=20
> Index: linux-2.6.17-mm4/drivers/net/8390.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.17-mm4.orig/drivers/net/8390.c
> +++ linux-2.6.17-mm4/drivers/net/8390.c
> @@ -299,7 +299,7 @@ static int ei_start_xmit(struct sk_buff=20
>  	 *	Slow phase with lock held.
>  	 */
>  	=20
> -	disable_irq_nosync(dev->irq);
> +	disable_irq_nosync_lockdep(dev->irq);
>  =09
>  	spin_lock(&ei_local->page_lock);
>  =09
> @@ -338,7 +338,7 @@ static int ei_start_xmit(struct sk_buff=20
>  		netif_stop_queue(dev);
>  		outb_p(ENISR_ALL, e8390_base + EN0_IMR);
>  		spin_unlock(&ei_local->page_lock);
> -		enable_irq(dev->irq);
> +		enable_irq_lockdep(dev->irq);
>  		ei_local->stat.tx_errors++;
>  		return 1;
>  	}
> @@ -379,7 +379,7 @@ static int ei_start_xmit(struct sk_buff=20
>  	outb_p(ENISR_ALL, e8390_base + EN0_IMR);
>  =09
>  	spin_unlock(&ei_local->page_lock);
> -	enable_irq(dev->irq);
> +	enable_irq_lockdep(dev->irq);
> =20
>  	dev_kfree_skb (skb);
>  	ei_local->stat.tx_bytes +=3D send_length;
> @@ -505,9 +505,9 @@ irqreturn_t ei_interrupt(int irq, void *
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  void ei_poll(struct net_device *dev)
>  {
> -	disable_irq(dev->irq);
> +	disable_irq_lockdep(dev->irq);
>  	ei_interrupt(dev->irq, dev, NULL);
> -	enable_irq(dev->irq);
> +	enable_irq_lockdep(dev->irq);
>  }
>  #endif


Reversed (or previously applied) patch detected!=20

Wrong patch ? This one won't apply, it seems to be already=20
applied to 2.6.18-rc1-mm1.

--=20
laurent
