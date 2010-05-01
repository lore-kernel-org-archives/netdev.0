From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: sock_def_readable() and friends RCU
 conversion
Date: Sat, 01 May 2010 06:56:04 +0200
Message-ID: <1272689764.2230.15.camel@edumazet-laptop>
References: <1272549408.4258.189.camel@bigi> <1272573383.3969.8.camel@bigi>
	 <1272574909.2209.150.camel@edumazet-laptop>
	 <20100430.163519.133415203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, xiaosuo@gmail.com, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org, eilong@broadcom.com,
	bmb@athenacr.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:38753 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846Ab0EAE4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 00:56:11 -0400
Received: by bwz19 with SMTP id 19so471903bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 21:56:08 -0700 (PDT)
In-Reply-To: <20100430.163519.133415203.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 30 avril 2010 =C3=A0 16:35 -0700, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 29 Apr 2010 23:01:49 +0200
>=20
> > [PATCH net-next-2.6] net: sock_def_readable() and friends RCU conve=
rsion
>=20
> So what's the difference between call_rcu() freeing this little waitq=
ueue
> struct and doing it for the entire socket?
>=20
> We'll still be doing an RCU call every socket destroy, and now we als=
o have
> a new memory allocation/free per connection.
>=20
> This has to show up in things like 'lat_connect' and friends, does it=
 not?

Difference is this structure is small, one cache line at most.

So the cost of call_rcu() on this structure, with the well known cache
miss is very much reduced.

The thing that might cost is the smp_mb(), because it translate to a
"mfence" instruction, and it appears to cost more than a a regular
"lock ..."

Unfortunatly, oprofile doesnt work anymore on my bl460c machine after
last BIOS upgrade... Oh well...



