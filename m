From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 14:15:38 -0500
Message-ID: <4B311ADA.4000700@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <20091222075742.GB26467@elte.hu> <4B3103B4.4070708@gmail.com> <4B3115C1.4070303@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig8A6C4C5A6F8543D443E2BFB9"
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Avi Kivity <avi@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754810AbZLVTPu@vger.kernel.org>
In-Reply-To: <4B3115C1.4070303@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig8A6C4C5A6F8543D443E2BFB9
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/22/09 1:53 PM, Avi Kivity wrote:
> I asked why the irqfd/ioeventfd mechanisms are insufficient, and you di=
d not reply.
>=20

BTW: the ioeventfd issue just fell through the cracks, so sorry about
that.  Note that I have no specific issue with irqfd ever since the
lockless IRQ injection code was added.

ioeventfd turned out to be suboptimal for me in the fast path for two
reasons:

1) the underlying eventfd is called in atomic context.  I had posted
patches to Davide to address that limitation, but I believe he rejected
them on the grounds that they are only relevant to KVM.

2) it cannot retain the data field passed in the PIO.  I wanted to have
one vector that could tell me what value was written, and this cannot be
expressed in ioeventfd.

Based on this, it was a better decision to add a ioevent interface to
xinterface.  It neatly solves both problems.

Kind Regards,
-Greg


--------------enig8A6C4C5A6F8543D443E2BFB9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksxGtoACgkQP5K2CMvXmqHYNwCeKP6FucL9dVcuOFWM/WV1rAdR
gZYAn14u1/O/su3G+m1jvb1lTa8lCXN+
=ydvF
-----END PGP SIGNATURE-----

--------------enig8A6C4C5A6F8543D443E2BFB9--
