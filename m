From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 2.6] iptables CLUSTERIP target
Date: Thu, 21 Oct 2004 16:25:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021142527.GG3551@sunbeam.de.gnumonks.org>
References: <20041020223828.GP19899@sunbeam.de.gnumonks.org> <20041021075530.GA1278@infradead.org> <20041021091229.GA3551@sunbeam.de.gnumonks.org> <20041021110513.GA21579@outpost.ds9a.nl> <20041021130327.GD3551@sunbeam.de.gnumonks.org> <20041021133346.GL3911@marowsky-bree.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Wb5NtZlyOqqy58h0"
Cc: bert hubert <ahu@ds9a.nl>, Christoph Hellwig <hch@infradead.org>,
        Linux Netdev List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lars Marowsky-Bree <lmb@suse.de>
Content-Disposition: inline
In-Reply-To: <20041021133346.GL3911@marowsky-bree.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Wb5NtZlyOqqy58h0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 21, 2004 at 03:33:46PM +0200, Lars Marowsky-Bree wrote:

> If the proc file IO for communicating with the module goes away in
> favour of a commandline based add/list/remove/etc interface, that would
> just help to tidy up our code, so it's OK with me.

I'm not a big fan of inventing new kernel/userspace interfaces.  We
don't have any associated device, so we don't have any ioctl()s or stuff
like that.

For supporting two primitive operation, adding a new netlink address
family also isn't worthwhile, especially since we're short of netlink
families.

Using the iptables getsockopt/setsockopt interface also is not possible,
since it cannot be extended.

So instead of introducing a new syscall, I think /proc is just the right
way to deal with this :)

I've now converted it to use seq_file, still need to do some testing.
The initial reason not to use seq_file was that=20

1) I thought seq_file files cannot be writeable. =20
2) We don't actually need to dump a table with dozesn of entries, just
   a small number of integer numbers, thus seq_file seemed a bit like
   overkill.

This assumption '1' seems to be wrong, I now provide my own write
function to struct file_operations.

Let me give it some testing, I'll re-submit it later today or tomorrow.

> > > And yes, I've received hate mail over this from switch engineers :-)
> > Why is that?  They have to deal with multicast traffic, too...  and I
> > don't really see how this is any different.
>=20
> Yeah, but with this they get a whole lot more ;-)

I didn't read any ethernet-related specification that said it is safe to
assume nobody uses multicast.

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--Wb5NtZlyOqqy58h0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBd8bXXaXGVTD0i/8RAsbVAKCXVzfPHHyfqUvjtP/Eo47v74mFBgCfcNZa
WMm8ZZBDgAHoMjoxbCb/C0s=
=InmV
-----END PGP SIGNATURE-----

--Wb5NtZlyOqqy58h0--
