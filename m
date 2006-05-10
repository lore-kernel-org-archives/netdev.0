From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: Dscape ieee80211: enabling/disabling the radio
Date: Wed, 10 May 2006 15:37:11 +0200
Message-ID: <200605101537.15213.IvDoorn@gmail.com>
References: <200605061401.01795.IvDoorn@gmail.com> <200605100001.20180.IvDoorn@gmail.com> <200605091836.10138.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1847391.3fMDU7WrJV";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Olivier <o.cornu@gmail.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:48419 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964959AbWEJNfp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 09:35:45 -0400
Received: by nf-out-0910.google.com with SMTP id p46so1269727nfa
        for <netdev@vger.kernel.org>; Wed, 10 May 2006 06:35:44 -0700 (PDT)
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200605091836.10138.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1847391.3fMDU7WrJV
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 10 May 2006 00:36, Michael Wu wrote:
> On Tuesday 09 May 2006 18:01, Ivo van Doorn wrote:
> > A user on the forums Olivier Cornu (added to the CC list) has done some
> > investigation into the scanning behaviour of the dscape stack.
> > Basicly the dscape stack is performing active scanning while the device=
 is
> > down, but during the active scan it is sending packets out, or at least
> > attempting to do so. Besides the question if active scanning is preferr=
ed
> > over passive scanning while interface is down, active scanning fails
> > because the packets that should be send are being send through the regu=
lar
> > xmit routines of the interface. (IFF_UP is not set for the interface)
> >
> > This means that besides enabling the radio which should be done in the
> > driver, the stack should either bring up the interface when doing an ac=
tive
> > scan, or resort to passive scanning while interface is down.
> >
> If you can passive scan while the interface is down, I don't think it's r=
eally=20
> down. In adm8211, nothing can be sent or received when the interface is d=
own.=20
> The radio is always off when the interface is down. Taking the interface =
up=20
> just for a scan and then taking it back down doesn't sound too good eithe=
r. I=20
> think scans should be prohibited while the interface is down, since leavi=
ng=20
> the interface on isn't gonna do anything bad unless you put in the info t=
o=20
> associate.

True, I agree here. But when rt2x00 was using the ipw stack a much
requested feature from users was to be able to perform scanning while
interface was down. (The requests did not specify if it they wanted passive=
 or active scanning)
But the reason for these requests was that some user space applications and=
/or
distribution network scripts relied on the fact that the driver was capable=
 of scanning
while the interface was down, so the interface would only be brought up at =
boot time,
when there was no desired AP in the scan result.
I don't know which distributions or user space application these were, but =
due to the amount
of these requests it had been considered an important feature.

Ivo

--nextPart1847391.3fMDU7WrJV
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEYeyLaqndE37Em0gRAv4OAKDh13S5tOjfuYtNuBo9vudHxG8eSQCfWUmf
E4ND8ob0va9JKFcUfrF1f34=
=DdsN
-----END PGP SIGNATURE-----

--nextPart1847391.3fMDU7WrJV--
