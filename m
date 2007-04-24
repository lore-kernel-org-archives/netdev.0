From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] Fix build errors on 32bit platforms with new ktime
Date: Wed, 25 Apr 2007 00:15:15 +0200
Message-ID: <1177452915.30986.61.camel@localhost.localdomain>
References: <20070425.011028.113320997.yoshfuji@linux-ipv6.org>
	 <20070424183827.adb60ae0.dada1@cosmosbay.com>
	 <20070424100420.2860db68@dxpl.pdx.osdl.net>
	 <20070425.065539.104129657.yoshfuji@linux-ipv6.org>
	 <20070424145754.1a37f666@dxpl.pdx.osdl.net>
Reply-To: tglx@linutronix.de
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>, dada1@cosmosbay.com, bunk@stusta.de,
	davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([213.239.205.134]:33007 "EHLO mail.tglx.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1423159AbXDXWNa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 18:13:30 -0400
In-Reply-To: <20070424145754.1a37f666@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-04-24 at 14:57 -0700, Stephen Hemminger wrote:
> On Wed, 25 Apr 2007 06:55:39 +0900 (JST)
> YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E  <yoshfuji@l=
inux-ipv6.org> wrote:
>=20
> > In article <20070424100420.2860db68@dxpl.pdx.osdl.net> (at Tue, 24 =
Apr 2007 10:04:20 -0700), Stephen Hemminger <shemminger@linux-foundatio=
n.org> says:
> >=20
> > > Yoshifuji-san had the right idea, but ktime_to_us needs to be def=
ined
> > > in a way that works on both 64 and 32bit platforms.
> >=20
> > No, this does not cure.
> > > =20
> > > +#define ktime_to_us(kt)			((kt).tv64 / NSEC_PER_SEC)
> > > +
> >=20
> > NSEC_PER_USEC?
>=20
> On 64 bit platforms, ktime stores nano-seconds in a 64 bit value, so
> this is correct.

Err, nsec_value / NSEC_PER_SEC results in seconds AFAICS

nsec_value / NSEC_PER_USEC gives you microseconds

> >=20
> > > +static inline s64 ktime_to_us(const ktime_t kt)
> > > +{
> > > +	return (s64) kt.tv_sec * USEC_PER_SEC + kt.tv_nsec / NSEC_PER_U=
SEC;
> > > +}
> > > +
> >=20
> > Please do NOT use division here, which was the source of the
> > linkage error, and the reason why I posted a patch to use
> > ktime_to_timeval().
>=20
> On 32 bit platforms, ktime stores as two 32 bit values. Therefore the
> division is only 32bit and therefore okay.

Nope.

#if BITS_PER_LONG !=3D 64 && !defined(CONFIG_KTIME_SCALAR)
=2E...

and on i386

config KTIME_SCALAR
        bool
        default y

so you take the=20

ktime_to_timeval is probably the right way for it.

	tglx


