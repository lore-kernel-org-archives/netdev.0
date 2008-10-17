From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH] ibm_newemac: Fix new MAL feature handling
Date: Fri, 17 Oct 2008 09:09:01 -0400
Message-ID: <20081017090901.637c1ea5@zod.rchland.ibm.com>
References: <20081015213337.a99a9595.akpm@linux-foundation.org>
	<1224133010.8157.543.camel@pasglop>
	<20081016143840.GA29805@yoda.jdub.homelinux.org>
	<200810171456.53599.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:44179 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753253AbYJQNJG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 09:09:06 -0400
In-Reply-To: <200810171456.53599.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Oct 2008 14:56:52 +0200
Arnd Bergmann <arnd@arndb.de> wrote:

> On Thursday 16 October 2008, Josh Boyer wrote:
> > +#ifdef CONFIG_PPC_DCR_NATIVE
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (mal_has_feature=
(mal, MAL_FTR_CLEAR_ICINTSTAT))
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0mtdcri(SDR0, DCRN_SDR_ICINTSTAT,
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0(mfdcri(SDR0, DCRN_S=
DR_ICINTSTAT) | ICINTSTAT_ICTX));
> > +#endif
> > =C2=A0
>=20
> So what if you have a mmio based DRC implementation and still want to=
 use
> this feature?

You have to have hardware that does that.  When it exists, we can
probably worry about it.  Hopefully that will never happen.  (Axon is
an abomination that should not be repeated.)

> I guess you really should use dcr_read/dcr_write here instead of mtdc=
r/mfdcr.

We can look at that.  It's not going to be high on my TODO list at the
moment though.  (hint, there are other places that do the same thing
here and they should all be cleaned up if we're going to bother.)

josh
