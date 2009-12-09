From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] llc: convert the socket list to RCU locking (was
 Re: [PATCH 3/4] llc: use a device based hash table to speed up multicast
 delivery)
Date: Wed, 09 Dec 2009 23:34:37 +0100
Message-ID: <4B2025FD.3030106@gmail.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com> <4B20064C.7070301@gmail.com> <200912092236.06298.opurdila@ixiacom.com> <200912092349.26264.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43287 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758246AbZLIWeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 17:34:36 -0500
In-Reply-To: <200912092349.26264.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/12/2009 22:49, Octavian Purdila a =E9crit :
> On Wednesday 09 December 2009 22:36:06 you wrote:
> =20
>> I think I have everything  (in my head :) ) that I need now to come =
back
>>  with a v2 llc patch set now.=20
>=20
> Hmm, not really :) I still can't see how we can do multicast delivery=
 only with RCU when we need to restart the lookup.
>=20
> I think you mentioned that it is actually possible to do this for UDP=
, but I didn't found out how :-?

A patch is coming for this, it might need a seqlock (instead of a spinl=
ock).

Do the list lookup and take a refcount on all matching sockets, store p=
ointers in a 'stack'.

If lookup was sucessful, then multicast packet to all sockets present i=
n stack.

>=20
> Also, I think we need to restart the lookup even when only one list i=
s used, when we found out that the object is either free or not the one=
 we were looking for, since the current object might have been added to=
 the end of the=20
> list, thus short circuiting our search. E.g.:
>=20

Not necessary, because a socket is always added at front of the list.

You have a guarantee that you examined all sockets at least once.

But it doesnt matter so much anyway, because you dont want a single lis=
t :)

