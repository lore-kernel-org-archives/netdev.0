From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [Cbe-oss-dev] [PATCH 12/15] spidernet: increase the NAPI weight
Date: Thu, 14 Jun 2007 17:08:29 -0500
Message-ID: <20070614220829.GX4397@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <20070611190236.GL13741@austin.ibm.com> <4670502C.5000506@garzik.org> <200706132249.51894.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:38499 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751588AbXFNWIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2007 18:08:31 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5EM8Ui3006679
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 18:08:30 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5EM8UNf559044
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 18:08:30 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5EM8Uhi030061
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 18:08:30 -0400
Content-Disposition: inline
In-Reply-To: <200706132249.51894.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 13, 2007 at 10:49:51PM +0200, Arnd Bergmann wrote:
> On Wednesday 13 June 2007, Jeff Garzik wrote:
> > > +/* We really really want to empty the ring buffer every time,
> > > + * so as to avoid the RX ram full bug. So set te napi wieght
> > > + * to the ring size.
> > > + */
> > > +#define SPIDER_NET_NAPI_WEIGHT=A0=A0=A0=A0=A0=A0=A0SPIDER_NET_RX=
_DESCRIPTORS_DEFAULT
> >=20
> > I don't see why spider_net should have a different NAPI weight from=
=20
> > other drivers

It was a lame attempt to try to trick napi into draining the entire
RX queue in one go, with the goal of avoiding the dreaded rx ram full.
I'm not sure it made much of a difference, so we can let this slide.

> Would it help to do it the other way round, as in

No, that would shorten the RX queue, thus making it more likely
to overflow. At gigabit speeds, its petty easy to fill this thing
up multiple times per jiffy. The driver should continue to operate=20
either way, but the larger queue should keep it from being a busy=20
beaver.

--linas
