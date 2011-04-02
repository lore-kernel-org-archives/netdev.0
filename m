From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp: disallow bind() to reuse addr/port regression in 2.6.38
Date: Sat, 02 Apr 2011 23:18:03 +0200
Message-ID: <1301779083.2837.30.camel@edumazet-laptop>
References: <201104022001.48144.cyril.bonte@free.fr>
	 <1301773495.2837.26.camel@edumazet-laptop> <20110402203727.GI5552@1wt.eu>
	 <201104022300.33826.cyril.bonte@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Willy Tarreau <w@1wt.eu>, netdev@vger.kernel.org,
	Daniel Baluta <daniel.baluta@gmail.com>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	Charles Duffy <charles@dyfis.net>
To: Cyril =?ISO-8859-1?Q?Bont=E9?= <cyril.bonte@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56504 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756391Ab1DBVSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2011 17:18:10 -0400
Received: by wya21 with SMTP id 21so3800667wya.19
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2011 14:18:09 -0700 (PDT)
In-Reply-To: <201104022300.33826.cyril.bonte@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 02 avril 2011 =C3=A0 23:00 +0200, Cyril Bont=C3=A9 a =C3=A9cr=
it :
> Le samedi 2 avril 2011 22:37:27, Willy Tarreau a =C3=A9crit :
> > On Sat, Apr 02, 2011 at 09:44:55PM +0200, Eric Dumazet wrote:
> > > Is Cyril program running OK on FreeBsd ?
> >=20
> > I don't think so, as from memories, both FreeBSD and OpenBSD fail
> > on isten() after a shutdown(SHUT_RD), hence the strange looking
> > shut+listen+shut sequence you noticed (in order to detect whether
> > listen will work again or not).
>=20
> Well, I've just tested it on FreeBSD 8.1.
> As Willy said, the listen() fails but what I observe is that as soon =
as=20
> shutdown(SHUT_RW) is called, it is possible to bind a new socket on t=
he same=20
> port. A modified version of the program to sleep after the shutdown s=
hows that=20
> launching 3 processes in parallel (delayed to let them bind then shut=
down)=20
> will give 3 connections in CLOSE state.
>=20

Yes, but as soon as shutdown(SHUT_RDWR) is called on socket fd1, is thi=
s
same socket reusable ?

Maybe the only possible action is a close(fd1), and socket not any more
bound.

Man page on shutdown() is a bit silent, and makes sense for non
listening sockets.



