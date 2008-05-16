From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH] [NET] uli526x: add support for netpoll
Date: Fri, 16 May 2008 15:13:49 +0400
Message-ID: <20080516111349.GA27587@polina.dev.rtsoft.ru>
References: <20080515151255.GA12408@polina.dev.rtsoft.ru> <200805152251.24137.florian.fainelli@telecomint.eu>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:40547 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1751255AbYEPLNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 07:13:52 -0400
Content-Disposition: inline
In-Reply-To: <200805152251.24137.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2008 at 10:51:23PM +0200, Florian Fainelli wrote:
> Hello Anton,
>=20
> Le Thursday 15 May 2008 17:12:55 Anton Vorontsov, vous avez =C3=A9cri=
t=C2=A0:
> > +#ifdef CONFIG_NET_POLL_CONTROLLER
> > +static void uli526x_poll(struct net_device *dev)
> > +{
> > +	/* ISR grabs the irqsave lock, so this should be safe */
> > +	uli526x_interrupt(dev->irq, dev);
> > +}
> > +#endif
>=20
> You do not need to wrap this function into the ifdef, since setting t=
he poll=20
> callback is between ifdef. Otherwise patch looks good.

Nope, I need this #ifdef, otherwise gcc will warn about unused function
if netpoll is not selected.

Of course, I could do __maybe_unused, but #ifdef is what most (all?)
drivers are doing.

--=20
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
