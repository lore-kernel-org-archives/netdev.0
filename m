From: Dan Siemon <dan@coverfire.com>
Subject: PMTU problem with >2.6.38 and IPIP tunnels
Date: Sat, 23 Jul 2011 21:40:49 -0400
Message-ID: <1311471668.10268.12.camel@ganymede>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-nZ6uHYj7HlQDMSt0a5Ie"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.coverfire.com ([69.41.199.58]:53270 "EHLO
	alpha.coverfire.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938Ab1GXCnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 22:43:25 -0400
Received: from [192.168.88.98] (milv-rb-2-stat-199-68.nblk1.cyg.net [69.41.199.68])
	(authenticated bits=0)
	by alpha.coverfire.com (8.14.4/8.14.4) with ESMTP id p6O1f726010275
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2011 21:41:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-nZ6uHYj7HlQDMSt0a5Ie
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I'm running into some MTU related problems with kernels newer than
2.6.38. I've tried bisecting and it appears the problem was introduced
between 2.6.39rc2 and rc3 but I'm not 100% certain because the problem
does not always present itself immediately. I am certain this does not
occur with 2.6.38.8.

I tunnel all of my home network traffic over an IPIP tunnel. My Internet
access is DSL based so there's a PPPoE connection as well. Both ends of
the IPIP tunnel are Linux.

When the gateway is first booted with the problem kernel everything is
fine. Using 'show ip route cache' I see MTU entries with the correct
values. After a short period the MTU on all the routes starts dropping
in what often appears to be 20 byte increments.

show ip route cache | egrep -i mtu
cache <src-direct>  expires 435sec ipid 0x28de mtu 712 iif eth1
cache <src-direct>  expires 542sec ipid 0x66e8 mtu 672 iif eth1

Until eventually all routes show a MTU of 552.

I'd be happy to run tests if anyone has an idea of what is causing this.

--=-nZ6uHYj7HlQDMSt0a5Ie
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCAAGBQJOK3ghAAoJEJKXGLoTP2w+pjoQAImEGOiSdhUKF/NYbWZ5/0OQ
Qj+0NFGyX9ejvMJ4lc8gh94eEKx5bpyv3xuBgsndWr002p88hnpB7pQT71IgC+pu
23VkI791bo0k1Nr7ZKqT1+YOVthCG5a5+2spe/YtRsGPFbtsWPpjK08kPiRkLqYY
lNukG2XvpWHRXikyc3yLkCgShQhh1jmqMUQQXpwa2oUr46ocyNLHPomAB6OZJnQP
NPn3vafjlemUgQZb6gaRoaXHzPT9k3wimdLwGK1Dtb9K9gUgfp9dcWEI9kTTTk3A
OV+9xS6pMWtU5lC1OQ3sslsDNxs1csqaEBZQLS/VKIpo0u+kCNqipIorwIl89A3U
7BnXE28ERNzdY+S1uk5Cn4/nNJB7nHzjqcv33Q4XgfKKqMCsgGDO/HPQedNW6OwZ
HcSpph0C24pMhDvwo/BH4X9jfj1JWeGx4eC7JUyfvItaJMeWhdWe+vG579EplfMH
QGrjC17y/mXE2EZpHrrfwBXARPqIV/RTvUt77pNjZE8zyMCXM8lG7QvretT3Xlti
jH6CWu1FnmwmKbTSbo68nOgP7rQRV5kYYLWeEEjegHmm6GSRFGQHmie0/lS9Z+Hs
YU/nU7Uy02YA2ROmVxEU5r0FQE+rew2imkotThQsGzyHcGfr4Dwm8AdTxk/J5JXQ
q4t73nGaCpZkRp6F2vR/
=yp16
-----END PGP SIGNATURE-----

--=-nZ6uHYj7HlQDMSt0a5Ie--

