From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: mac80211 truesize bugs
Date: Thu, 01 May 2008 11:08:06 +0200
Message-ID: <1209632886.4008.8.camel@johannes.berg>
References: <1209607368.7173.20.camel@johannes.berg>
	 <200805011058.40197.mb@bu3sch.de> (sfid-20080501_105856_166245_19C68544)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ie9Xk7oTnGTHnuBqQWPH"
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:60438 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756699AbYEAJIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 05:08:45 -0400
In-Reply-To: <200805011058.40197.mb@bu3sch.de> (sfid-20080501_105856_166245_19C68544)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ie9Xk7oTnGTHnuBqQWPH
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> Hm, unrelated to this...
> But I am wondering what happens if the driver adds a device header to the=
 skb.
> Is that header then also passed up netif_rx()?
> This doesn't happen for b43, as we use the DMA fragmentation to transmit =
the header,
> but it might happen for zd1211rw and others.

Hmm. I thought we said that it was supposed to be removed again by the
hardware before TX status reporting. That's what most drivers seem to do
anyway.

I'm considering turning off this transmit status reporting for now but
that will make hostapd not work.


> Seems the skb->destructor messes it up.

Actually, it seems to be outside of mac80211, I put in a WARN_ON() and
got this:

Badness at include/linux/skbuff.h:392
NIP: c026ea14 LR: c0273d54 CTR: c026e9e4
REGS: edfc7c00 TRAP: 0700   Not tainted  (2.6.25-wl-06841-g6b3d5c6-dirty)
MSR: 00029032 <EE,ME,IR,DR>  CR: 82022444  XER: 00000000
TASK =3D edf50e20[3453] 'tcpdump' THREAD: edfc6000
GPR00: 00000001 edfc7cb0 edf50e20 edfd7700 edfd7700 00000002 edfc7e75 03230=
306=20
GPR08: 02000100 00000168 4dff0200 00000150 22022442 100a6290 100783f8 10078=
e18=20
GPR16: 10078e14 10078e10 100a0000 00000000 00000000 bfe2c9d2 1004d320 bfe2c=
4b0=20
GPR24: 10165070 edfd7724 00000060 00000020 ed8157f0 edfd7700 ed8157f0 edfd7=
700=20
NIP [c026ea14] sock_rfree+0x30/0x94
LR [c0273d54] skb_release_all+0x98/0x128
Call Trace:
[edfc7cb0] [10078e10] 0x10078e10 (unreliable)
[edfc7cc0] [c0273d54] skb_release_all+0x98/0x128
[edfc7cd0] [c0273034] __kfree_skb+0x18/0xc8
[edfc7ce0] [c02760d0] skb_free_datagram+0x1c/0x54
[edfc7cf0] [f264d068] packet_recvmsg+0x170/0x1e8 [af_packet]
[edfc7d40] [c026b69c] sock_recvmsg+0xb8/0xf0
[edfc7e30] [c026b9d0] sys_recvfrom+0x94/0x100
[edfc7f00] [c026ca08] sys_socketcall+0x114/0x1dc
[edfc7f40] [c00124cc] ret_from_syscall+0x0/0x38

johannes

--=-ie9Xk7oTnGTHnuBqQWPH
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBmIdaVg1VMiehFYAQI+YRAArHCm3ZGYzJ60xeByc6Whu9fO2hbvYskJ
bli3R9JuzHRVHf7i+wQA29zAaOxFG5/XZC/Am5E9MqlMecJLeb0hEQ0TuacvOI5f
f6+6oRf3TFkw1wv1cxOveyzADnRTlhpPFX/ZqLmvLIBNR9nBeqadaclmF0yjzJAO
nJ1SdGGUCf7mwHaBQLxsE4fQ9UJiNZT4UL/vZbkldbnGJBa9W+QteI+cQKEgXeo5
9XSRqfl2Yj6fc3d+ALcVaEvHcrfIJFDNPw/xxcpvIhqz7RyeMoWeebRf1prqiJ3h
u0WyKrrw7d85RpqKhSmKH3z9DeVx/zfTM1eT5dO1jiMfkVL12HoFgaZrcgycemAG
Bu1L0uR06hyBCRFosB3dYe7sa3azT11mLjx2fcsQeCC+drbaS7Rit8ik+gSgrX2k
xbhPBvFBMpU3hHYyKttadY0GpnL/RLzbsD7RqrlYPDs/T+3rGpPPQLemFufySvnM
LgBkOtzGcMoerBWucP1tv1VzuLNdRNmuZ1FVOiISPG/jpWY4CGB6mO7anSwFs3T2
DWOyH17LyiSKieKB3Zjjmk1E0QQmOGVJvg9ZEMYaqT1sQ16lwP7T+6IM7nN7SSdK
wlfnaGkPphs2RLQ5la9gODIkYV5u72vjTeEwo86FnYFAN54seSH5svswIGJMthjp
KNggZPgDu24=
=3uXF
-----END PGP SIGNATURE-----

--=-ie9Xk7oTnGTHnuBqQWPH--

