From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: How to use ixp4xx_hss (or generic-hdlc?)
Date: Mon, 24 Nov 2008 17:33:41 +0100
Message-ID: <m3ljv913tm.fsf@maximus.localdomain>
References: <b0438a630811200942nac803a4hb0c054bf28195cb3@mail.gmail.com>
	<20081120222431.GA16068@electric-eye.fr.zoreil.com>
	<b0438a630811210018j38518462ve975dfd3a7220b00@mail.gmail.com>
	<m37i6wslpr.fsf@maximus.localdomain>
	<b0438a630811240156u161af1em917c7b4d35fe019a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Francois Romieu" <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:50607 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751920AbYKXQdn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 11:33:43 -0500
In-Reply-To: <b0438a630811240156u161af1em917c7b4d35fe019a@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Mon\, 24 Nov
 2008 10\:56\:23 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:

> I am not sure of having understood you. The buffer I send using sendt=
o
> should be just the payload and the generic-hdlc (or the hardware)
> encapsulates it in an hdlc frame, or should I prepare the whole
> frame?

You sendto() the payload, but what is a payload?

With a normal HDLC hw driver, it (and the hardware) will generate the
flag sequences, will do bit-(de)stuffing, will calculate and check the
checksums, residual bits, aborts etc.

You usually have to add 32-bit header: u8 address (broadcast,
multicast, unicast) and control (such as unnumbered frame type), and
u16 protocol number (IPv4, IPv6 etc, LCP/IPCP, Cisco keepalive etc).
That's why it's called "raw HDLC", you're dealing with raw HDLC
packets.

> I took a little different approach, using the same PF_PACKET socket t=
o
> obtain the ifr_ifindex, but in any case using your method or "my"
> method, and activating the debugging in ixp4xx_hss, when I do a two
> byte (0x30 0x31) sendto, the traces in debug_pkt give me:
>
> 1970/01/01,00:00:47 (none) user.debug kernel: hdlc0: hss_hdlc_xmit(2)
> <7> 30<7>31<7>

It should do just that (those '<7>' are weird, though).
--=20
Krzysztof Halasa
