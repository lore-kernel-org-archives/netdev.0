From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: Re: [RFC v2] virtio: add virtio-over-PCI driver
Date: Thu, 26 Feb 2009 17:53:56 +0100 (CET)
Message-ID: <alpine.LRH.2.00.0902261752310.29190@vixen.sonytel.be>
References: <20090224000002.GA578@ovro.caltech.edu> <200902261715.28440.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ira Snyder <iws@ovro.caltech.edu>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org,
	Jan-Bernd Themann <THEMANN@de.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vervifontaine.sonytel.be ([80.88.33.193]:57092 "EHLO
	vervifontaine.sonycom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755212AbZBZQx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 11:53:59 -0500
In-Reply-To: <200902261715.28440.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Feb 2009, Arnd Bergmann wrote:
> On Tuesday 24 February 2009, Ira Snyder wrote:
> > +/* Virtio-over-PCI descriptors: 12 bytes. These can chain together=
 via "next" */
> > +struct vop_desc {
> > +	/* Address (host physical) */
> > +	__le32 addr;
               ^^^^
Only 32-bit? Is this future-proof?

> > +	/* Length (bytes) */
> > +	__le32 len;
> > +	/* Flags */
> > +	__le16 flags;
> > +	/* Chaining for descriptors */
> > +	__le16 next;
> > +} __attribute__((packed));
>=20
> I would drop the "packed" attribute in the structure definitions.
> It would imply that only byte accesses are allowed on these
> data structures, because the attribute invalidates any assumptions
> about alignment. None of your structures require padding, so
> the attribute does not have any positive effect either.
>=20
> > +/* MPC8349EMDS specific get_immrbase() */
> > +#include <sysdev/fsl_soc.h>
>=20
> Do you really need get_immrbase? I would expect that you can find
> all the registers you need in the device tree, or exported from
> other low-level drivers per subsystem.
>=20
> immrbase is a concept from the time before our device trees.
>=20
> > +/*
> > + * These are internal use only versions of the structures that
> > + * are exported over PCI by this driver
> > + *
> > + * They are used internally to keep track of the PowerPC queues so=
 that
> > + * we don't have to keep flipping endianness all the time
> > + */
> > +struct vop_loc_desc {
> > +	u32 addr;
        ^^^
Same here.

With kind regards,

Geert Uytterhoeven
Software Architect

Sony Techsoft Centre Europe
The Corporate Village =B7 Da Vincilaan 7-D1 =B7 B-1935 Zaventem =B7 Bel=
gium

Phone:    +32 (0)2 700 8453
=46ax:      +32 (0)2 700 8622
E-mail:   Geert.Uytterhoeven@sonycom.com
Internet: http://www.sony-europe.com/

A division of Sony Europe (Belgium) N.V.
VAT BE 0413.825.160 =B7 RPR Brussels
=46ortis =B7 BIC GEBABEBB =B7 IBAN BE41293037680010
