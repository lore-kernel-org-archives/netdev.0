From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 23:52:20 +0200
Message-ID: <1305669140.6741.4.camel@edumazet-laptop>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	 <1305663288.2691.2.camel@edumazet-laptop>  <m2aaelypbp.fsf@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62733 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984Ab1EQVwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:52:24 -0400
Received: by wya21 with SMTP id 21so750515wya.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 14:52:23 -0700 (PDT)
In-Reply-To: <m2aaelypbp.fsf@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 17 mai 2011 =C3=A0 14:44 -0700, Andi Kleen a =C3=A9crit :
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> >
> > OK but do we have workloads actually needing this optimization at a=
ll ?
>=20
> That's a good a question.
> >
> > (IP defrag hits a read_lock(&ip4_frags.lock)), so maybe steer all f=
rags
> > on a given cpu ?)
>=20
> Couldn't the lock just be replaced with a hashed or bitmap lock or=20
> bit in low bits of pointer lock?
>=20
> iirc it just protects the heads of the hash table.
>=20
> They're not rwlocks, but especially if the locking was more finegrain=
ed
> that's likely not needed anymore.

Well, there is the rehashing stuff, and this locks the whole table.

Not easy to switch to rcu or something like that.

Anyway I hardly use frags here at work, so never considered it was a
field to spend time ;)



