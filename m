From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Tue, 17 Mar 2009 16:21:24 +0100
Message-ID: <49BFBFF4.5060206@cosmosbay.com>
References: <20090316233934.GD32111@codeblau.de> <49BF0A5A.2040501@hp.com> <20090317125845.GB9754@codeblau.de> <49BFA9F0.6070702@hp.com> <20090317141432.GA10575@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
To: Felix von Leitner <felix-kernel@fefe.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60093 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbZCQPVz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 11:21:55 -0400
In-Reply-To: <20090317141432.GA10575@codeblau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46elix von Leitner a =E9crit :
>> Sorry, I just don't buy this.  You imply that you don't want the ove=
rhead
>> of storing IPv6 addresses, but you still get this with ::ffff:0.0.0.=
0.
>> In fact, now your overhead is even worse since ever IPv4 address wil=
l be
>> stored stored and interpreted as IPv6 128 bit address.
>=20
>> If you really care about overhead, run 2 services.  Your IPv6 servic=
e
>> will only track real IPv6 addresses and will reduce you total overhe=
ad.
>=20
> I am worried about the overhead of storing the IPv6 addresses.
> I am not storing them in the IPv4 case.
>=20
> But the socket code has been rewritten to use IPv6 addresses only,
> precisely because IPv4-mapped addresses exist.
>=20
>> If you don't care about overhead, just bind a single socket to :: an=
d
>> you will get behavior identical for the ::fff:0.0.0.0 case, but with
>> the added benefit of tracking real ipv6 addresses as well.
>=20
> You probably mean well but please stick to the problem at hand and do=
n't
> speculate about my app.
>=20
>> Having written support for ::ffff:0.0.0.0, I've always thought it wa=
s
>> a bastardized case that didn't provide any benefits.  It was like sa=
ying:
>> "I've got IPv6 on my system, but I don't really support it, even tho=
ugh
>> I pretend that I do."
>=20
> The app has a command line option to specify which address to bind to=
=2E
> The app understands IPv4 addresses and converts them to ipv4 mapped
> addresses so it can only deal with sockaddr_in6 when talking to the
> kernel and does not need to store info on what kind of socket family =
it
> is dealing with.
>=20
> If someone specifies 0.0.0.0, it does not work.  It's that easy.
>=20
> Now it may be a fascinating side discussion on whether you think IPv4
> mapped 0.0.0.0 is useful or not, but rest assured: it is useful to at
> least one high profile app that is so far running on Linux.
>=20
>>> Why would you say that?
>> Because that case doesn't provide any benefits.
>=20
> You may not see it but it does.
>=20
>> It only has the drawback that you have to deal with ipv4-mapped IPv6
>> addresses witch is the overhead of the whole thing.
>=20
> That is not a drawback.  On the contrary.  It greatly simplifies how =
the
> app deals with the socket API.
>=20
>> If you are prepared to deal with it, you might as well deal with rea=
l ipv6 addresses
>> at the same time and mitigate your overhead somewhat.
>=20
> You are currently proving all the snide remarks by the BSD people abo=
ut
> the Linux IP stack true, and the "professionalism" snide remarks of t=
he
> Solaris people.  Great work, man.
>

Trying to understand why you seem furious, lets try to be pragmatic.

Most users of your great program wont have a fix for this until next ye=
ar.

I am afraid you have no choice but change your program, or loose users.

Still I dont get your point. Having TCP V6 sockets is much more expensi=
ve
at kernel level (same for UDP), and bittorrent is known to stress netwo=
rk a bit, so
having application use an IPV4 socket where it can is a win for your
program getting more users, and computers spend less power.

grep TCP /proc/slabinfo

tw_sock_TCPv6          0      0    192   21    1 : tunables    0    0  =
  0 : slabdata      0      0      0
TCPv6                140    140   1600   20    8 : tunables    0    0  =
  0 : slabdata      7      7      0
tw_sock_TCP          256    256    128   32    1 : tunables    0    0  =
  0 : slabdata      8      8      0
TCP                  197    198   1472   22    8 : tunables    0    0  =
  0 : slabdata      9      9      0


Gasp, OSX having this "::ffff:0.0.0.0" right is probably the reason why=
 more computers
 run OSX than linux. Sometime dont implement RFC too literally :)




