From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: NAPI documentation needed
Date: Thu, 20 Dec 2012 20:09:54 +0000
Message-ID: <1356034194.2889.9.camel@bwh-desktop.uk.solarflarecom.com>
References: <CACna6rzG3KcMYUpMZv-wv6e62J9j1NLuZpTRSQHLpyfTTbKyUg@mail.gmail.com>
	 <1356033878.21834.3163.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24548 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298Ab2LTUKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 15:10:00 -0500
In-Reply-To: <1356033878.21834.3163.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-20 at 12:04 -0800, Eric Dumazet wrote:
> On Thu, 2012-12-20 at 20:39 +0100, Rafa=C5=82 Mi=C5=82ecki wrote:
> > I wanted to report some problem I've encouraged during bgmac driver=
 development.
> >=20
> > At the very beginning I've implemented IRQ using threaded IRQ
> > (request_threaded_irq). I didn't know about NAPI until someone poin=
ted
> > me that mistake. So I decided to rewrite IRQs handling to use NAPI.
> > I've found following documents:
> > http://www.linuxfoundation.org/collaborate/workgroups/networking/na=
pi
> > ftp://robur.slu.se/pub/Linux/net-development/NAPI/README
> > ftp://robur.slu.se/pub/Linux/net-development/NAPI/NAPI_HOWTO.txt
> > ftp://robur.slu.se/pub/Linux/net-development/NAPI/converting-to-NAP=
I.txt~
> > but nothing really official sitting in kernel's Documentation dir.
> >=20
> > So I started to using found documents, but then noticed they are qu=
ite outdated.
> >=20
> > 1) We don't have netif_rx_schedule and netif_rx_complete anymore.
> > 2) We don't set poll and weight manually anymore but use netif_napi=
_add
> > 3) Return type and arguments has changed in poll. None of the
> > following is up-to-date:
> > static void my_poll (struct net_device *dev, int *budget)
> > int (*poll)(struct net_device *dev, int *budget);
> >=20
> > It would be great if someone with NAPI knowledge could document it =
in
> > a kernel. Would be really helpful for new network drivers developer=
s.
>=20
> I think you might be the one to update/create the official NAPI
> documentation, now ideas are clear for you.
>=20
> That would be really great indeed.

It would.  Last time someone asked, my answer was:

> The initial change to napi_struct is explained in
> <http://lwn.net/Articles/244640/>.
>=20
> Since then there have been further changes:
>=20
> - netif_napi_del() has been added.  You must call it to clean up NAPI
> contexts before freeing the associated net device(s).
>=20
> - Instead of netif_rx_schedule(), netif_rx_complete(), etc. you must =
use
> napi_schedule(), napi_complete() etc. which just take a napi_struct
> pointer.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
