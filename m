From: "Zimmermann, Alexander" <Alexander.Zimmermann@netapp.com>
Subject: Re: TCP reordering and Multiple DL path
Date: Tue, 11 Mar 2014 14:40:00 +0000
Message-ID: <71451900-EEAF-484D-BA3B-26628F4082B4@netapp.com>
References: <AB9D0874A51C404B8D86602911E629521A9E0D4D@IRSMSX102.ger.corp.intel.com>
 <1394468108.3607.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_EDCD5692-F5CA-4CDA-B868-3F902F19F45E";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "Soum, Redouane" <redouane.soum@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.netapp.com ([216.240.18.77]:13519 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751250AbaCKOkC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 10:40:02 -0400
In-Reply-To: <1394468108.3607.22.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_EDCD5692-F5CA-4CDA-B868-3F902F19F45E
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


Am 10.03.2014 um 17:15 schrieb Eric Dumazet <eric.dumazet@gmail.com>:

> On Mon, 2014-03-10 at 15:44 +0000, Soum, Redouane wrote:
>> Hi,
>>=20
>> I have several path in DL between an Application Processor and a =
Modem
>> using different network interfaces (USB CDC NCMs) with the same ip
>> address (connected to the same network)
>>=20
>> Having several network interfaces used in DL implies to have out of
>> order packets, even if the ooo packets will most likely come close
>> together.
>>=20
>> Here is my understanding on the impact on TCP throughput :
>>=20
>> -        OOO packets will lead to Dup acks.
>> -        When sender receives 3 Dup acks it'll start fast recovery
>> which will reduce TCP congestion window.
>>=20
>> First question is my understanding correct ?
>>=20
>> Assuming it is :=20
>> In order to solve that issue I am thinking to add a small delay =
before
>> sending dup acks for OoO packets.
>> The objective is to be sure that dup acks for OoO packets will only =
be
>> sent for OoO packet due to different path in the network, and not
>> because of the different network interfaces.
>>=20
>> However I am not sure how complex it would be to implement and which
>> part of the TCP stack need to be modified.
>> Any advice to solve that issue ?
>=20
> This is quite complex.

Indeed. They are currently some efforts in TCPM to specify a reordering
robust TCP. See

=
http://tools.ietf.org/id/draft-zimmermann-tcpm-reordering-detection-00.txt=

=
http://tools.ietf.org/html/draft-zimmermann-tcpm-reordering-reaction-00.tx=
t

Alex

>=20
> Note that we are working on a more generic solution, involving a high =
resolution timer,
> for not only this case, but more generally :
>=20
> Delayed ACK (application could tell TCP stack its max latency for RPC)
>=20
> TSO autodefer bugs (currently we rely on future ACKS, while we should
> not)
>=20
> TCP_CORK_US (extend TCP auto cork with a usec timer)
>=20
> Trick is to not add uncontrolled jitter on ACKs, otherwise we screw up
> delay based CC.
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Apple-Mail=_EDCD5692-F5CA-4CDA-B868-3F902F19F45E
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iEYEARECAAYFAlMfIEAACgkQdyiq39b9uS712QCfUDDblcJPvyOv0TxcjJKRoimq
ODgAoK05pnuzZcB1pVccNqGPi3auaMYM
=mVOF
-----END PGP SIGNATURE-----

--Apple-Mail=_EDCD5692-F5CA-4CDA-B868-3F902F19F45E--
