From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH v2 8/8] Document future removal of sysctl_tcp_* options
Date: Sun, 25 Oct 2009 20:21:14 -0400
Message-ID: <20091025202114.152b94b8.billfink@mindspring.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com>
	<1256115421-12714-9-git-send-email-gilad@codefidence.com>
	<4ADED6FA.2030502@gmail.com>
	<4ADEE119.7020803@codefidence.com>
	<4ADF616B.1090405@gmail.com>
	<20091022003245.5cd4885c.billfink@mindspring.com>
	<4ADFE635.4020109@gmail.com>
	<4AE415DD.5050406@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	netdev@vger.kernel.org
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:34675 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753969AbZJZAVO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Oct 2009 20:21:14 -0400
In-Reply-To: <4AE415DD.5050406@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 25 Oct 2009, Gilad Ben-Yossef wrote:

> Eric Dumazet wrote:
>=20
> > Bill Fink a =E9crit :
> >
> >  =20
> >> And as mentioned previously, the global options can be quite usefu=
l
> >> in certain test scenarios.  I also agree the per route settings ar=
e
> >> a very useful addition.  I think the global and per route settings
> >> are complementary and shouldn't be thought of as in conflict with
> >> one another.
> >>    =20
> > Absolutely, global setting is a must when an admin wants a quick pa=
th.
> >
> > The more flexible would be to have two bits per route, plus
> > 2 bits on the global configuration.
> >
> > global conf:
> > 00 : timestamps OFF, unless a route setting is not 00
> > 01 : timestamps ON, unless a route setting is not 00
> > 10 : Force timestamps OFF, ignore route settings (emergency sysadmi=
n request)
> > 11 : Force timestamps ON, ignore route settings=20
> >
> > Route settings (used *only* if global setting is 0Y)
> > 00 : global conf is used
> > 01 : Force timestamps being OFF for this route
> > 10 : Force timestamps being ON for this route
> > 11 : complement global conf
>=20
> Hey, I have no issue to re-spin the patch with this suggestion, if yo=
u=20
> truly think this is valuable, but would you please consider the=20
> nightmare of having to just explain this to someone?
>=20
> It sounds to me way too complicated for what it does.
>=20
> I still think having a global kill switch and per route options bette=
r=20
> (basically use the exiting patch but not retire the global kill=20
> switch|), but if you must Hgow about we leave the global sysctl as th=
ey=20
> are and just have a two bit route option:
>=20
> 0 Use global default
> 1 Off
> 2 On
>=20
> It's kind of funny, because this is what the original patch from=20
> Comsleep does and I thought it needlessly complicates things.
>=20
> So, what do you say - which will it be?

I personally feel the 2-bit settings are overkill.  What i think
makes the most sense is for the global options to act as they always
have in the absence of any route specific settings, and for any
route specific settings to override the related global settings.
This is both simple and maintains backward compatibility.

						-Bill
