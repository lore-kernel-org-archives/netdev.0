From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Mon, 02 Jan 2012 16:59:03 +0100
Message-ID: <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:53528 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800Ab2ABP7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 10:59:06 -0500
Received: by werm1 with SMTP id m1so7471017wer.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 07:59:05 -0800 (PST)
In-Reply-To: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 02 janvier 2012 =C3=A0 16:21 +0100, Jean-Michel Hautbois a =C3=
=A9crit :
> Hi all,
>=20
> I am currently working on a way to send raw images (~400*300 YUV
> 4:2:0) at a relative high speed (raw image and not compressed image
> due to specific codec issues).
> This would represent about 57MBps/sec on a 100Mbps ethernet link.
> This link is direct, nothing else will pass through it.
>=20
> My question is a performance and efficiency question. Here is what I
> am thinking about :
> - I have the image on one computer at a known memory adress
> - I want top transmit this picture using TCP packets with the rule
> "1row =3D 1packet", maybe "2rows=3D1packet"
> - All these packets have to go on an ethernet link and will be
> received on another computer starting at a known memory adress
> Something like this :
> http://imageshack.us/photo/my-images/15/tcpmemory.png/
>=20
> I was thinking about using TCP socket (of course) and the sendfile
> syscall on sender side, splice syscall on the receiver side, but I
> don't know if this is the best (and fastest) way to do it ?
> I would like to avoid memory copy as much as possible as the systems
> on which it will be done are embedded arm computers.
> TCP is chosen in order to get ordered packets, but maybe am I wrong ?
>=20
> Thanks for any clues you can give !
> Regards,
> JM
> --

Do you really need full image, or are some missing lines allowed ?

What is the length in bytes for a line ?

TCP stream and your bandwidth requirements would work only if you
guarantee not a single packet loss.

Using UDP (RTP) would allow you to respect any time limits at the
sender, yet allowing some drops on the network.

If you use a direct link, packets wont be re-ordered.

Is your ARM platform so slow it cannot afford copying 10 Mbytes per
second in skb ?
