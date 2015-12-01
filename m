From: Daniele Fucini <dfucini@gmail.com>
Subject: Re: size overflow in function qdisc_tree_decrease_qlen
 net/sched/sch_api.c
Date: Tue, 1 Dec 2015 12:19:43 +0100
Message-ID: <20151201111943.GA4036@Fux-PC>
References: <20151201010005.GA23175@Fux-PC>
 <CAHA+R7NdbMgfWpdCoP8peXT3zBX1=B_HWhsykjcT3QO=Gk-9aQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="EVF5PPMfhYS0aIcm"
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, spender@grsecurity.net,
	pageexec@freemail.hu, re.emese@gmail.com
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33502 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbbLALTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 06:19:47 -0500
Received: by wmuu63 with SMTP id u63so1361957wmu.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 03:19:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAHA+R7NdbMgfWpdCoP8peXT3zBX1=B_HWhsykjcT3QO=Gk-9aQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Thanks for the reply. Here's the output of `tc qdisc show`:
https://gist.github.com/1847102c8fe08f63e9e7

Daniele


On Mon, Nov 30, 2015 at 08:50:29PM -0800, Cong Wang wrote:
> On Mon, Nov 30, 2015 at 5:00 PM, Daniele Fucini <dfucini@gmail.com> wrote:
> > Hello,
> >
> > I'm using a Grsecurity patched kernel (version 4.2.6-201511282239) and
> > I'm getting system freezes due to PaX detecting a size overflow in
> > function qdisc_tree_decrease_qlen net/sched/sch_api.c:769 whenever I use
> > Transmission BitTorrent client.
> >
> > On the Grsecurity forum I was told it's probably an unintended integer
> > underflow that I should report upstream.
> >
> > Here's the relevant log:
> > https://gist.github.com/cf54ccbb12ea65e146d4
> >
>=20
> Looks like we miss some sch->q.qlen accounting somewhere...
>=20
> What is your qdisc setup? Is your fq_codel the default one or you install=
ed it
> or some other qdisc somewhere (`tc qdisc show` could tell)?
>=20
> I will take a deeper look tomorrow, or maybe Jamal could find something
> before I wake up. ;)

--EVF5PPMfhYS0aIcm
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWXYJPAAoJEEYRza8bUKw+n1oIAKc9IA1T/EUUDGOJ3/pm4sAn
0vNzWloH8eRNzdYMmu+nJrMuGpXEv/91Dwz/Angc83fg5Wg5fCYn7hr60MasqXMX
tb1u3jrwK6uYqL0hGoCJgtnbVIIdxtE5M8+pbE6MnUFFgEBHYIWEEVg9A8ovmBZ7
pbsEJLzsseAicJDqG/66jzmPKaNMNk40lMrihwwYt0j14XOEKNYwmrkfbIVhR0SQ
ng4x2dtyc07DWv+V9wnbc/u6Nn7Ny0oiizAziT41q+siX2ea0qnkSGss9SaIUrwx
X8/aZDG3LYYc4oBrsvE4ac0VycBqS3LjM/XlJe8kuz7YCdVGWp4nWw95ngIjzVc=
=5Sgc
-----END PGP SIGNATURE-----

--EVF5PPMfhYS0aIcm--
