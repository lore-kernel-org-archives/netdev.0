From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Splice status
Date: Mon, 26 Jul 2010 22:50:01 +0200
Message-ID: <1280177401.2531.13.camel@edumazet-laptop>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
	 <AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
	 <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
	 <1278334254.2877.158.camel@edumazet-laptop>
	 <AANLkTim_eBmT-6HmkqG5d7k0jjrGKAFBjzqVCricTpgK@mail.gmail.com>
	 <1278388580.2466.305.camel@edumazet-laptop>
	 <AANLkTinRnDwMOS5NrmzKqYZpczG4nfHSvKA9Gw-_UUzO@mail.gmail.com>
	 <EE71107DF0D1F24FA2D95041E64AB9E8ED254E7B66@IL-MB01.marvell.com>
	 <1279030308.2634.349.camel@edumazet-laptop>
	 <EE71107DF0D1F24FA2D95041E64AB9E80114797BC8AB@IL-MB01.marvell.com>
	 <4C4DF220.1050307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ofer Heifetz <oferh@marvell.com>, Changli Gao <xiaosuo@gmail.com>,
	Jens Axboe <axboe@kernel.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:57060 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847Ab0GZUuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 16:50:06 -0400
Received: by wwf26 with SMTP id 26so3224051wwf.1
        for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 13:50:05 -0700 (PDT)
In-Reply-To: <4C4DF220.1050307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 juillet 2010 =C3=A0 22:37 +0200, Jarek Poplawski a =C3=A9cr=
it :
> Ofer Heifetz wrote, On 25.07.2010 16:47:
>=20
> > Hi Eric,
> >=20
> > Still trying to get better performance with splice, I noticed that =
when using splice there are twice the file size memcpy (placed a counte=
r in memcpy), I verified it via samba file transfer and splice-fromnet/=
out.
> >=20
> > I also used the splice-fromnet/out and using ftrace I did notice th=
at data is copied twice using these routines: skb_splice_bits, pipe_to_=
file.
>=20
>=20
> I'm not sure you're using optimal NIC for splice, which should use
> skbs with almost all data paged (non-linear), like niu or myri10ge.
>=20
> Jarek P.

Yes, I dont think splice() _should_ be faster, with a NIC delivering
frames of 1460 (or less bytes), when disk IO should be performed with 4
Kbytes blocs (or a multiple) to get good performance.

sendfile(file -> socket) is fast because blocs are pages, but
splice(socket -> file) is not fast, unless the NIC is able to perform
tcp receive offload.

To take an analogy, think about libc stdio versus read(2)/write(2)
syscalls. stdio, while doing copies in intermediate buffers, is able to
be faster than read()/write() in most cases.

Using splice() with 1460 bytes frames is like using read()/write()
instead of nice sized buffers given by stdio layer.

zero-copy can hurt badly if the IO sizes are not page aligned.



