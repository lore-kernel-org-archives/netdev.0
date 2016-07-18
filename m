From: "Eggert, Lars" <lars@netapp.com>
Subject: Re: [CRIU] TCP_REPAIR MSS issue
Date: Mon, 18 Jul 2016 09:06:05 +0000
Message-ID: <6B535C6E-88BF-4613-816D-7898DB21044C@netapp.com>
References: <C6D17923-7965-4483-8604-C654BFF1E0FF@netapp.com>
 <575FEA4B.2000603@virtuozzo.com>
 <3758708E-B5DE-4D8B-A8CC-37346F994B32@netapp.com>
 <20160614171528.GA14276@outlook.office365.com>
 <EE75D5F9-7243-4DE0-94FE-F6279939C231@netapp.com>
 <20160614205741.GB20722@outlook.office365.com>
 <5A6E3EFB-2B69-4C3C-BC67-CAFEC5B2DB2C@netapp.com>
 <20160616210902.GB6010@outlook.office365.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_F2E2929C-DC12-4524-8A9F-5C1E7DE2054E";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Pavel Emelyanov <xemul@virtuozzo.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"criu@openvz.org" <criu@openvz.org>,
	"Honda, Michio" <michio@netapp.com>
To: Andrey Vagin <avagin@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:20045 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751459AbcGRJGH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 05:06:07 -0400
In-Reply-To: <20160616210902.GB6010@outlook.office365.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_F2E2929C-DC12-4524-8A9F-5C1E7DE2054E
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Hi,


On 2016-06-16, at 23:09, Andrey Vagin <avagin@virtuozzo.com> wrote:
> I can't reproduce this issue, now I'm trying to understand why it =
works
> for me and doesn't work for you.

just to conclude this thread for the list:

Andrey and me debugged this off-list. The issue arose, because my code =
did a bind() to 0.0.0.0 in TCP_REPAIR mode. When turning off TCP_REPAIR =
and sending into the socket, this caused minimum-MSS-sized segments to =
be transmitted. The issue goes away when I bind() to the local IP =
address of my local egress interface.

To me at least, this is a POLA violation (excuse the FreeBSD terminology =
:-) Either binding to 0.0.0.0 should fail, or it should succeed and =
full-sized segments should be sent. But at least I have a work-around =
now.

Thanks,
Lars

--Apple-Mail=_F2E2929C-DC12-4524-8A9F-5C1E7DE2054E
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJXjJv7AAoJEFS1wwm/cMFXCL0QAMY0T7DyrbNB4VXG4bsvFnjd
geZc1SM2YtKBqTc1/8M6Oki0YDr4HFka7BKzIMjCzy9gy0Jn20NEojXyEjdeh/OY
uleHqTiVXvNh83MVMstWQta1bKcyCMd9a6NiRXpj4Ot4VdL6J7G7BoB9NwhJdykt
Z0QEn+Dmo126QXgVysn3U5OmSxah5v1qSpprp50Fx4o5tT2V0B54doDWqcG03NPq
MSw5Dh7k9+3n8jqmumdzYIXXqfTqF8CoBhc4rJMfCK5fyNlAmNnmhISDDNnRjADW
s2vRG4c9eZtdXvCWOs7mc09OHz9JpNb107C8Pcf7RmL1ojGL1ipL46DQArH8zeKH
9w50RN5te3RUONVSPwdi3ZhRumvfVuZcKhLymFKjYpnMk/odSr5Fxzf1i4yHB/6u
7L6mvfDpUdYPdCfQ+8/QO+Sj7bQtY2aLDqA592meAb0z/nnXLqy8otYrYkGaETx9
HorLtx1Pwyw0OFnJ0ixiQThOrg6kRr6POlPsypDfaybsmYRwhJrcZJxRbNPUIYTE
yExokf2CIqTmUW/E3+Il+KGSqzgXtUGZuOcfsp0qwdUxfd/7p+Ezeqo04Yi2Xm7/
xYS2IdcxjsJHqrDqdElK9HFsX7agQB5tfamgF2qN0+AqbfhcWww75d5bGgVe2AK1
SOiTnRvIGz0SclKy8MZ1
=uWKT
-----END PGP SIGNATURE-----

--Apple-Mail=_F2E2929C-DC12-4524-8A9F-5C1E7DE2054E--
