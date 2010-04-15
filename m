From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Network multiqueue question
Date: Thu, 15 Apr 2010 19:47:17 +0200
Message-ID: <1271353637.16881.2846.camel@edumazet-laptop>
References: <i2tb65cae941004150958n5c66dc42j26724bbb075125a0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "George B." <georgeb@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:42318 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046Ab0DORr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 13:47:27 -0400
Received: by bwz25 with SMTP id 25so1929511bwz.28
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 10:47:26 -0700 (PDT)
In-Reply-To: <i2tb65cae941004150958n5c66dc42j26724bbb075125a0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 09:58 -0700, George B. a =C3=A9crit :
> I am in need of a little education on multiqueue and was wondering if
> someone here might be able to help me.
>=20
> Given intel igb network driver, it appears I can do something like:
>=20
>  tc qdisc del dev eth0 root handle 1: multiq
>=20
> which works and reports 4 bands:  dev eth0 root refcnt 4 bands 4/4
>=20
> But our network is a little more complicated.  Above the ethernet we
> have the bonding driver which is using mode 2 bonding with two
> ethernet slaves.  Then we have vlans on the bond interface.  Our
> production traffic is on a vlan and resource contention is an issue a=
s
> these are busy machines.
>=20
> It is my understanding that the vlan driver became multiqueue aware i=
n
> 2.6.32 (we are currently using 2.6.31).
>=20
> It would seem that the first thing the kernel would encounter with
> traffic headed out would be the vlan interface, and then the bond
> interface, and then the physical ethernet interface.  Is that correct=
?
>  So with my kernel, I would seem to get no utility from multiq on the
> ethernet interface if the vlan interface is going to be a
> single-threaded bottleneck.  What about the bond driver?  Is it
> currently multiqueue aware?
>=20
> I am try to get some sort of logical picture of how all these things
> interact with each other to get things a little more efficient and
> reduce resource contention in the application while still trying to b=
e
> efficient in use of network ports/interfaces.
>=20
> If someone feels up to the task of sending a little education my way,
> I would be most appreciative.  There doesn't seem to be a whole lot o=
f
> documentation floating around about multiqueue other than a blurb of
> text in the kernel and David's presentation of last year.

Hi George

Vlan is multiqueue aware, but bonding is not unfortunatly at this
moment.

We could let it being 'multiqueue' (a patch was submitted by Oleg A.
Arkhangelsky a while ago), but bonding xmit routine needs to lock a
central lock, shared by all queues, so it wont be very efficient...

Since this bothers me a bit, I will probably work on this in a near
future. (adding real multiqueue capability and RCU to bonding fast
paths)

Ref: http://permalink.gmane.org/gmane.linux.network/152987


