From: Henrik Austad <henrik@austad.us>
Subject: Re: [very-RFC 6/8] Add TSN event-tracing
Date: Mon, 13 Jun 2016 09:20:50 +0200
Message-ID: <20160613072050.GA19180@sisyphus.home.austad.us>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <1465686096-22156-7-git-send-email-henrik@austad.us>
 <20160612125803.27f401cc@gandalf.local.home>
 <20160612212510.GD32724@icarus.home.austad.us>
 <20160612222201.00a8aa4c@grimm.local.home>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0990673572057120740=="
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 "David S. Miller" <davem@davemloft.net>, Ingo Molnar <mingo@redhat.com>,
 Henrik Austad <haustad@cisco.com>, alsa-devel@vger.kernel.org,
 linux-media@vger.kernel.org
To: alsa-devel@alsa-project.org
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20160612222201.00a8aa4c@grimm.local.home>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org


--===============0990673572057120740==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="17pEHd4RhPHOinZp"
Content-Disposition: inline


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jun 12, 2016 at 10:22:01PM -0400, Steven Rostedt wrote:
> On Sun, 12 Jun 2016 23:25:10 +0200
> Henrik Austad <henrik@austad.us> wrote:
>=20
> > > > +#include <linux/if_ether.h>
> > > > +#include <linux/if_vlan.h>
> > > > +/* #include <linux/skbuff.h> */
> > > > +
> > > > +/* FIXME: update to TRACE_CLASS to reduce overhead */ =20
> > >=20
> > > I'm curious to why I didn't do this now. A class would make less
> > > duplication of typing too ;-) =20
> >=20
> > Yeah, I found this in a really great article written by some tracing-du=
de,=20
> > I hear he talks really, really fast!
>=20
> I plead the 5th!
>=20
> >=20
> > https://lwn.net/Articles/381064/
> >=20
> > > > +TRACE_EVENT(tsn_buffer_write,
> > > > +
> > > > +	TP_PROTO(struct tsn_link *link,
> > > > +		size_t bytes),
> > > > +
> > > > +	TP_ARGS(link, bytes),
> > > > +
> > > > +	TP_STRUCT__entry(
> > > > +		__field(u64, stream_id)
> > > > +		__field(size_t, size)
> > > > +		__field(size_t, bsize)
> > > > +		__field(size_t, size_left)
> > > > +		__field(void *, buffer)
> > > > +		__field(void *, head)
> > > > +		__field(void *, tail)
> > > > +		__field(void *, end)
> > > > +		),
> > > > +
> > > > +	TP_fast_assign(
> > > > +		__entry->stream_id =3D link->stream_id;
> > > > +		__entry->size =3D bytes;
> > > > +		__entry->bsize =3D link->used_buffer_size;
> > > > +		__entry->size_left =3D (link->head - link->tail) % link->used_bu=
ffer_size; =20
> > >=20
> > > Move this logic into the print statement, since you save head and tai=
l. =20
> >=20
> > Ok, any particular reason?
>=20
> Because it removes calculations during the trace. The calculations done
> in TP_printk() are done at the time of reading the trace, and
> calculations done in TP_fast_assign() are done during the recording and
> hence adding more overhead to the trace itself.

Aha! that makes sense, thanks!
(/me goes and updates the tracing-part)

-Henrik

--17pEHd4RhPHOinZp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAldeXtIACgkQ6k5VT6v45lmmJwCgwoV2qvp1oqEZC3y+CcunA4vR
taAAnjprjT9Tawz7dspUySmX4AkaxB4S
=804g
-----END PGP SIGNATURE-----

--17pEHd4RhPHOinZp--
--
To unsubscribe from this list: send the line "unsubscribe alsa-devel" in


--===============0990673572057120740==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0990673572057120740==--
