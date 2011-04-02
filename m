From: Cyril =?iso-8859-1?q?Bont=E9?= <cyril.bonte@free.fr>
Subject: Re: tcp: disallow bind() to reuse addr/port regression in 2.6.38
Date: Sat, 2 Apr 2011 23:00:33 +0200
Message-ID: <201104022300.33826.cyril.bonte@free.fr>
References: <201104022001.48144.cyril.bonte@free.fr> <1301773495.2837.26.camel@edumazet-laptop> <20110402203727.GI5552@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Willy Tarreau <w@1wt.eu>, netdev@vger.kernel.org,
	Daniel Baluta <daniel.baluta@gmail.com>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	Charles Duffy <charles@dyfis.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:40674 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756572Ab1DBVAn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2011 17:00:43 -0400
In-Reply-To: <20110402203727.GI5552@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 2 avril 2011 22:37:27, Willy Tarreau a =E9crit :
> On Sat, Apr 02, 2011 at 09:44:55PM +0200, Eric Dumazet wrote:
> > Is Cyril program running OK on FreeBsd ?
>=20
> I don't think so, as from memories, both FreeBSD and OpenBSD fail
> on isten() after a shutdown(SHUT_RD), hence the strange looking
> shut+listen+shut sequence you noticed (in order to detect whether
> listen will work again or not).

Well, I've just tested it on FreeBSD 8.1.
As Willy said, the listen() fails but what I observe is that as soon as=
=20
shutdown(SHUT_RW) is called, it is possible to bind a new socket on the=
 same=20
port. A modified version of the program to sleep after the shutdown sho=
ws that=20
launching 3 processes in parallel (delayed to let them bind then shutdo=
wn)=20
will give 3 connections in CLOSE state.

--=20
Cyril Bont=E9
