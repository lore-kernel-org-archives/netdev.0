From: Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/6] crc-itu-t: add bit-reversed calculation
Date: Sun, 21 Jun 2009 12:18:25 +0200
Message-ID: <200906211218.25709.IvDoorn@gmail.com>
References: <1244021629-18409-1-git-send-email-dbaryshkov@gmail.com> <1244033004.21215.4.camel@deadeye> <20090621082921.GA12749@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>,
	Darren Salt <linux-Ym6Ivm/Ks7B65+NM0QMiFAbYiX8G1TQY9dF7HbQ/qKg@public.gmane.org>
To: "Dmitry Eremin-Solenikov" <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090621082921.GA12749-nIupHZaCssqR2kOLt6zJ8ErlnG4Plg33XqFh9Ls21Oc@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[non-HTML reply, sorry about that]

On Sunday 21 June 2009, Dmitry Eremin-Solenikov wrote:
> Hi,
>=20
>=20
> On Wed, Jun 03, 2009 at 01:43:24PM +0100, Ben Hutchings wrote:
> > On Wed, 2009-06-03 at 13:33 +0400, Dmitry Eremin-Solenikov wrote:
> > [...]=20
> > > +/**
> > > + * crc_itu_t_bitreversed - Compute the CRC-ITU-T for the data bu=
ffer;
> > > + * the buffer content is assumed to be bit-reversed
> > [...]
> >=20
> > This short description spills onto two lines which is invalid and b=
reaks
> > the generation of docs.  Sorry to point this out after recommending=
 the
> > patch to you.
> >=20
> > I've changed the description to "crc_itu_t_bitreversed - Compute th=
e
> > CRC-ITU-T for a bit-reversed data buffer" all on one line.
>=20
> Just another not w.r.t. this patch: one should add 'select BITREVERSE=
'
> to this Kconfig entry, as it depends on bitreversing stuff.

What also might be interesting, =A0have you checked the crc-ccitt algor=
ithm?
I had come across a crc_itu_t with bitreverse implementation in the pas=
t as
well, and I could simplify the implementation by using crc-ccit and onl=
y call
bitreverse on the last output. So something like:

u16 crc =3D crc_ccitt(~0, data, len);
u16 crc_itu_t =3D swab16(crc);

Instead of bitreverse for every step, only a single  byteswap was neede=
d.
You need to check if this indeed works for your driver, but this would
reduce the number of times bitrev is called, and also prevents the BITR=
EV
dependency for the crc implementation.

Ivo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
