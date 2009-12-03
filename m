From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4] llc: use a device based hash table to speed up multicast
 delivery
Date: Fri, 04 Dec 2009 00:52:44 +0100
Message-ID: <4B184F4C.3060407@gmail.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com> <1259879498-27860-4-git-send-email-opurdila@ixiacom.com> <4B1842EE.7030208@gmail.com> <200912040130.54966.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52507 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbZLCXwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 18:52:42 -0500
In-Reply-To: <200912040130.54966.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
>=20
> Yes, that is probably not appropriate for upstream. What would be a g=
ood=20
> value?
>=20

A small one to begin (say 64).

> Since at this point we are using UP ports contention is not really an=
 issue=20
> for us. I've extrapolated this (lock per hash bucket) based on how lo=
cking is=20
> done in other places, like UDP.=20

Yes but you know we want to remove those locks per UDP hash bucket, sin=
ce we dont
really need them anymore. ;)


If you remember, we had in the past one rwlock for the whole UDP table.

Then this was converted to one spinlock per hash slot (128 slots) + RCU=
 lookups for unicast RX

Then we dynamically sized udp table at boot (up to 65536 slots)

multicast optimization (holding lock for small duration + double hashin=
g)

bind optimization (thanks to double hashing)

To be done :

1) multicast RX can be done without taking any lock, and RCU lookups
2) zap all locks and use one lock, or a small array of hashed spinlocks


