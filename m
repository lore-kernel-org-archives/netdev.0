From: Simon Guinot <simon.guinot@sequanux.org>
Subject: Re: Problems with mvneta
Date: Tue, 31 Oct 2017 18:09:38 +0100
Message-ID: <20171031170938.GC18407@kw.sim.vm.gnt>
References: <20171018223425.42ce7a74@gmx.de>
 <20171018225557.43837338@windsurf.home>
 <20171020002524.4b4cf122@gmx.de>
 <20171020090956.2b6cc34b@windsurf.home>
 <01d0cd47-20ef-bbad-cd93-749cc94d0d2f@cloudguard.ch>
 <20171023113024.7138970e@r84n0nz>
 <20171031152322.3e180c30@gmx.de>
 <20171031152740.72ab6829@windsurf>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="2JFBq9zoW8cOFH7v"
Cc: Sven =?utf-8?Q?M=C3=BCller?= <musv@gmx.de>,
        Andreas Tobler <andreas.tobler@cloudguard.ch>,
        =?utf-8?Q?Gr=C3=A9gory?= Clement
        <gregory.clement@free-electrons.com>,
        Antoine =?utf-8?Q?T=C3=A9nart?=
        <antoine.tenart@free-electrons.com>, netdev@vger.kernel.org,
        Marcin Wojtas <mw@semihalf.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vm1.sequanux.org ([188.165.36.56]:57451 "EHLO vm1.sequanux.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932449AbdJaRS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 13:18:56 -0400
Content-Disposition: inline
In-Reply-To: <20171031152740.72ab6829@windsurf>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--2JFBq9zoW8cOFH7v
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 31, 2017 at 03:27:40PM +0100, Thomas Petazzoni wrote:
> Hello,

Hi Thomas,

>=20
> Let's add Simon Guinot in the loop.
>=20
> On Tue, 31 Oct 2017 15:23:22 +0100, Sven M=C3=BCller wrote:
> > After quite a long time of trying to reproduce the issue without any su=
ccess I got 3 network crashes today. And all errors occurred with a kernel =
including the patch:=20
> >=20
> > 2a90f7e1d5d04e4f1060268e0b55a2c702bbd67a
> >=20
> > At least according to Andreas' and my problems we can exclude the 6ad2 =
patch as the source of the errors.=20
>=20
> Simon, 2a90f7e1d5d04e4f1060268e0b55a2c702bbd67a is your commit, adding
> xmit_more support, and a number of people are reporting stability
> issues with this patch applied.

I wrote an earlier version of this patch. But I think this commit has
been modified by the submitter Marcin Wojtas because I don't remember
anything about the maximum number of descriptors allowed to be flush.

>=20
> Do you think you will have some time to look into this ?

No I don't have time to look into that.

But after a quick look, I wonder what is happening if
"txq->pending + frags > MVNETA_TXQ_DEC_SENT_MASK" ? Because IIUC
mvneta_txq_pend_desc_add() is called anyway. And according to the
comment inside the function, it assumes there is less than 255
descriptors to send... It looks suspect.

Simon

--2JFBq9zoW8cOFH7v
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAln4rlIACgkQgtp0PDeOcDoYfwCgh0XNBr1xcBbLKcovsgD8L7GK
eGgAnjF8nJipwA6fiLQEJuEchnegh8CL
=bPZ+
-----END PGP SIGNATURE-----

--2JFBq9zoW8cOFH7v--
