From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] dcache: better name hash function
Date: Tue, 27 Oct 2009 10:35:36 -0700
Message-ID: <20091027103536.28cf0a0f@nehalam>
References: <19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com>
	<4AE68E23.20205@gmail.com>
	<4AE69829.9070207@gmail.com>
	<4AE6A16F.4020002@gmail.com>
	<20091027100736.5303f1ab@nehalam>
	<4AE72B91.7040700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54997 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754150AbZJ0Rfh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 13:35:37 -0400
In-Reply-To: <4AE72B91.7040700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Oct 2009 18:19:13 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Stephen Hemminger a =C3=A9crit :
>=20
> > So Eric's string10 is fastest for special case of fooNNN style name=
s.
> > But probably isn't best for general strings. Orignal function
> > is >20% slower, which is surprising probably because of overhead
> > of 2 shifts and multipy. jenkins and fnv are both 10% slower.
> >=20
>=20
>=20
> jhash() is faster when strings are longer, being able to process 12 b=
ytes per loop.
>=20

But jhash is not amenable to usage in namei (with partial_name_hash).

name_hash is rarely done on long strings, the average length of a filen=
ame
is fairly short (probably leftover Unix legacy). On my system, average
path component length in /usr is 13 characters; therefore jhash has
no big benefit here.
