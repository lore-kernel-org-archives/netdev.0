From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: remove ip_rt_secret timer (v3)
Date: Fri, 07 May 2010 23:04:31 +0200
Message-ID: <1273266271.2325.16.camel@edumazet-laptop>
References: <20100506171639.GA5063@hmsreliant.think-freely.org>
	 <20100507195528.GA3752@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:64910 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758323Ab0EGVEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 17:04:41 -0400
Received: by bwz19 with SMTP id 19so812023bwz.21
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 14:04:39 -0700 (PDT)
In-Reply-To: <20100507195528.GA3752@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 mai 2010 =C3=A0 15:55 -0400, Neil Horman a =C3=A9crit :
> Hey-
> 	Sorry for the delay, but I got interested in Erics suggestion of
> changing how we update rt_genid, and had a few thoughts.  Heres versi=
on 3 of
> this patch:
>=20

We have time, no hurry Neil.

> Change Notes:
>=20
> 1) Removed the secret_interval binary interface entry in the list (fo=
rgot to do
> that before)
>=20
> 2) Took Erics Suggestion to change the update for net->ipv4.rt_genid.=
  Now
> instead of doing a small incremental change, we simply grab 32 new ra=
ndom bits.
>=20

My suggestion was to initialize _once_ at boot time, the _full_ 32bits.

Not to change the perturbations, they are very fine, and need no extra
CONFIG_SOME_MAGICAL_SWITCH.

We have a guarantee that no duplicates are delivered unless you perform
2^24 generations in a short period of time.

But because you want to change full 32bits, you need a complex dupcheck
thing ?

> 3) The change in (2) got me thinking that part of the reason we used =
the Jenkins
> hash in rt_genid was to ensure non-repetion of id's in a short time p=
eriod
> (which is important, so as not to inadvertently reuse route cache ent=
ries that
> should be getting expired).  While extra randomness makes it harder f=
or
> attackers to guess the secret, it makes it possible to return to prev=
iously
> guessed values as well (if they're lucky).  As such, I created a conf=
igurable
> option, CONFIG_GENID_DUPCHECK.  With this option on, the low order 8 =
bits of the
> genid are replaced with a rolling counter, that increments on each ne=
w genid.
> This creates in effect, a 256 deep list of previously used genid valu=
es.  In
> rt_drop we compare the genids for duplicates.  If we find that 2 geni=
d values
> have different indexes, but idential remaining bits, they are noted a=
s a repeat
> genid, and we call rt_cache_invalidate to generate a new genid and av=
oid the
> duplication problem.
>=20
>=20

This is not necessary and over engineering if you ask me.

You now rely on probabilistic rules, and depends on get_random_bytes()
be really random, or a new CONFIG setting...

What exact problem do you want to solve Neil ?

Please submit your initial patch, with the small changes :

1) Remove the secret_interval binary interface entry in the list=20

2) Initialize full 32bits at struct net init time.

Thanks



