From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP - RST flag
Date: Tue, 23 Aug 2011 23:50:20 +0200
Message-ID: <1314136220.4478.6.camel@edumazet-laptop>
References: <CAEnQRZAchYf-3-t7RRogfb0WogzY9ZF8rzMdtOeS1Vdvx7N4og@mail.gmail.com>
	 <1314132932.4478.0.camel@edumazet-laptop>
	 <CAEnQRZChkX0K_qWf-Gmu8YeAyxoOb7DTPvvbnA5YxSHEMj_J=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	kernelnewbies <kernelnewbies@kernelnewbies.org>
To: Daniel Baluta <daniel.baluta@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48786 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755806Ab1HWVuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 17:50:25 -0400
Received: by wyg24 with SMTP id 24so415927wyg.19
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2011 14:50:23 -0700 (PDT)
In-Reply-To: <CAEnQRZChkX0K_qWf-Gmu8YeAyxoOb7DTPvvbnA5YxSHEMj_J=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 24 ao=C3=BBt 2011 =C3=A0 00:32 +0300, Daniel Baluta a =C3=A9=
crit :
> On Tue, Aug 23, 2011 at 11:55 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:

> > TCP in RFC 1122 section 4.2.2.13:
> >
> >  "A host MAY implement a "half-duplex" TCP close sequence, so that =
an
> >  application that has called CLOSE cannot continue to read data fro=
m the
> >  connection. If such a host issues a CLOSE call while received data=
 is
> >  still pending in TCP, or if new data is received after CLOSE is ca=
lled,
> >  its TCP SHOULD send a RST to show that data was lost."
>=20
> So, this means that server's CLOSE operation is issued while received
> data is still pending? I will analyze ftp's server code, but this is =
strange
> since P4 [221 Have a nice day!\r\n] it is generated as a response for
> P3 [QUIT\r\n]. So P4 must have been fully received.
>=20

tcpdump only shows TCP stack did receive the frame, not that it was
_read_ by application.

Only strace could eventually say if the input queue was really drained
before the close().

Maybe server decided to close the connexion before reading the QUIT
command from client.

> Also, looking at the capture no data is received from the client afte=
r
> server calls CLOSE (P5) (there are only ACKs and FIN - P6, P7, P8).

That doesnt matter.

If data was received (and ACKnowledged by TCP stack) _before_ close(fd)=
,
but not yet read by application, TCP must send an RST to be RFC
compliant.
