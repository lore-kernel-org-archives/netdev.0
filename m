From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: sock_def_readable() and friends RCU
 conversion
Date: Sat, 01 May 2010 09:02:47 +0200
Message-ID: <1272697367.2230.106.camel@edumazet-laptop>
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
Received: from mail-bw0-f219.google.com ([209.85.218.219]:34271 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273Ab0EAHCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 03:02:54 -0400
Received: by bwz19 with SMTP id 19so492539bwz.21
        for <netdev@vger.kernel.org>; Sat, 01 May 2010 00:02:53 -0700 (PDT)
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

Before patch :

lat_connect -N 10 127.0.0.1
TCP/IP connection cost to 127.0.0.1: 27.8872 microseconds

After :

lat_connect -N 10 127.0.0.1
TCP/IP connection cost to 127.0.0.1: 20.7681 microseconds

Strange isnt it ?

(special care should be taken with this bench, as it leave many sockets
in TIME_WAIT state, so to get consistent numbers we have to wait a whil=
e
before restarting it)



