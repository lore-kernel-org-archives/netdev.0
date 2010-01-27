From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 0% cpu usasge after fresh boot or net restart but 10% CPU if
 kernel flush route cache
Date: Wed, 27 Jan 2010 22:18:08 +0100
Message-ID: <1264627088.2892.7.camel@edumazet-laptop>
References: <41ac0f9e1001260858o7d2a6a6dgb37ecfba5c325932@mail.gmail.com>
	 <1264605976.3197.8.camel@edumazet-laptop>
	 <41ac0f9e1001271153u333a5e2aq6f473ccc6e6d1e23@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: cold cold <nedkonedev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:51293 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914Ab0A0VSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 16:18:15 -0500
Received: by bwz19 with SMTP id 19so5205559bwz.28
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 13:18:14 -0800 (PST)
In-Reply-To: <41ac0f9e1001271153u333a5e2aq6f473ccc6e6d1e23@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 janvier 2010 =C3=A0 21:53 +0200, cold cold a =C3=A9crit =
:

>=20
> btw atm i have 1k ip on that router but plan to put 10k so route cach=
e
> will grow 10 time fast.
> i try to keep low  rhash_entries but garbage collector  is non stop
> running and eat CPU
> atm i have around 7k  entries per second for second for first minute.
>=20
> i think it will be better if i flush cache on secret interval instead
> of giving work to gc.
> i test with 512MB cache and CPU is 0% and flushing entire hash dont t=
ake a lot,
> I'm not sure is there some side effects from flushing.

=46lush is immediate, it only marks entries as invalid and they are
cleaned up later.

512 MB cache is quite small for your needs, each entry uses 384 bytes
(assuming you use a 64bit kernel)

In my experiments, I found using gc (and no flushing) was the most
reliable way to have an equilibrium.

WHen setting gc_interval to 1,  the garbage collector is fired every
second and handles 1/300 of entries, from a work queue (thus doesnt sto=
p
packets to be handled by irqs), in a smooth way.

You can post "perf top" results to check where cpu is consumed.


