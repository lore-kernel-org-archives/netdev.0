From: Hans de Goede <j.w.r.degoede@hhs.nl>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Tue, 26 Aug 2008 21:01:01 +0200
Message-ID: <48B452ED.1000308@hhs.nl>
References: <bug-459782-176318@bugzilla.redhat.com> <200808261549.m7QFnVUN032543@bz-web1.app.phx.redhat.com> <20080826163719.GA25066@redhat.com> <48B44C3F.6020006@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.versatel.nl ([62.58.50.88]:35471 "EHLO smtp1.versatel.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754829AbYHZSty (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 14:49:54 -0400
In-Reply-To: <48B44C3F.6020006@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Dave Jones a =E9crit :
>> Just had this bug reported against our development tree..
<snip>
>>  > [hans@localhost devel]$ time cat /proc/net/tcp
>>  > <snip>
>>  > real    0m0.520s
>>  > user    0m0.000s
>>  > sys     0m0.446s
>>  >  > Thats amazingly slow, esp as I only have 8 tcp connections ope=
n.
>>  >  > Some maybe usefull info: top reports a very high load (50%) fr=
om=20
>> soft IRQ's.
>>  >  > Anyways changing this to a kernel bug.
>>
>=20
> I wonder why this qualifies as a "kernel bug". This is a well known=20
> problem.
>=20

No its not, /proc/net/tcp may be slow in general but not *this* slow ..=
=2E

<snip>

>=20
> Time difference between /proc/net/tcp and netlink on a 4GB x86_64 mac=
hine :
>=20
> # dmesg | grep "TCP established hash"
> TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
> # time cat /proc/net/tcp >/dev/null
>=20
> real    0m0.091s
> user    0m0.001s
> sys     0m0.090s

As quoted above my idle x86_64, using the exact same hash table size, r=
unning=20
2.6.27-rc2.git1 uses 0.520 seconds for that same command, thats a diffe=
rence of=20
more then a factor 50 !!

This is not about /proc/net/tcp not being fast, this is about it haven =
gotten=20
slower by a factor of 50!

Also notice that this slowdown does not happen on i386.

Anyways I'll try 2.6.27-rc4 and report back with its results.

Regards,

Hans
