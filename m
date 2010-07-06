From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Splice status
Date: Tue, 06 Jul 2010 05:56:20 +0200
Message-ID: <1278388580.2466.305.camel@edumazet-laptop>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
	 <AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
	 <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
	 <1278334254.2877.158.camel@edumazet-laptop>
	 <AANLkTim_eBmT-6HmkqG5d7k0jjrGKAFBjzqVCricTpgK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jens Axboe <axboe@kernel.dk>, Ofer Heifetz <oferh@marvell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:53189 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897Ab0GFD41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 23:56:27 -0400
Received: by gxk23 with SMTP id 23so2756969gxk.19
        for <netdev@vger.kernel.org>; Mon, 05 Jul 2010 20:56:26 -0700 (PDT)
In-Reply-To: <AANLkTim_eBmT-6HmkqG5d7k0jjrGKAFBjzqVCricTpgK@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 juillet 2010 =C3=A0 10:01 +0800, Changli Gao a =C3=A9crit :
> On Mon, Jul 5, 2010 at 8:50 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > Le lundi 05 juillet 2010 =C3=A0 13:52 +0300, Ofer Heifetz a =C3=A9c=
rit :
> >> I am using Samba, so from my understanding of the source code, it
> > loops and performs splice(sock, pipe) and splice(pipe, fd). There i=
s no
> > flush of any sort in between.
> >>
> >> When you say drain you mean to flush all data to pipe?
> >>
> >
> > Draining pipe before splice() call would only trigger the bug less
> > often.
>=20
> If we don't drain the pipe before calling splice(2), the data spliced
> from pipe maybe not be what we expect. Then data corruption occurs.
>=20

This is not true. A pipe is a pipe is a buffer. You dont need it to be
empty when using it. Nowhere in documentation its stated.

However, a single skb can fill a pipe, even if "its empty"



> >
> > splice(sock, pipe) can block if caller dont use appropriate "non
> > blocking pipe' splice() mode, even if pipe is empty before a splice=
()
> > call.
>=20
> I don't think it is expected. The code of sys_recvfile is much like
> the sendfile(2) implementation in kernel. If sys_recvfile may block
> without non_block flag, sendfile(2) may block too.

Then it would be a bug. You might fix it easily.

Using splice() correctly (ie, not blocking on sock->pipe) should work
too.

Again, you can block on splice(sock, pipe), iff you have a second threa=
d
doing the opposite (pipe->file) in parallel to unblock you. But samba
recvfile algo is using a single thread.

>=20
> BTW: Samba can use sendfile(2) instead in sys_recvfile.
>=20


