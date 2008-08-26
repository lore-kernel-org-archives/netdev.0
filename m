From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Tue, 26 Aug 2008 22:39:06 +0200
Message-ID: <48B469EA.1010807@cosmosbay.com>
References: <bug-459782-176318@bugzilla.redhat.com> <200808261549.m7QFnVUN032543@bz-web1.app.phx.redhat.com> <20080826163719.GA25066@redhat.com> <48B44C3F.6020006@cosmosbay.com> <48B452ED.1000308@hhs.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
To: Hans de Goede <j.w.r.degoede@hhs.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.orange.fr ([80.12.242.18]:10267 "EHLO smtp19.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751911AbYHZV3W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 17:29:22 -0400
Received: from smtp19.orange.fr (mwinf1903 [172.22.129.25])
	by mwinf1920.orange.fr (SMTP Server) with ESMTP id 13A225C0F6F6
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 22:39:45 +0200 (CEST)
In-Reply-To: <48B452ED.1000308@hhs.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hans de Goede a =E9crit :
> Eric Dumazet wrote:
>> Dave Jones a =E9crit :
>>> Just had this bug reported against our development tree..
> <snip>
>>>  > [hans@localhost devel]$ time cat /proc/net/tcp
>>>  > <snip>
>>>  > real    0m0.520s
>>>  > user    0m0.000s
>>>  > sys     0m0.446s
>>>  >  > Thats amazingly slow, esp as I only have 8 tcp connections op=
en.
>>>  >  > Some maybe usefull info: top reports a very high load (50%)=20
>>> from soft IRQ's.
>>>  >  > Anyways changing this to a kernel bug.
>>>
>>
>> I wonder why this qualifies as a "kernel bug". This is a well known=20
>> problem.
>>
>=20
> No its not, /proc/net/tcp may be slow in general but not *this* slow =
=2E..
>=20
> <snip>
>=20
>>
>> Time difference between /proc/net/tcp and netlink on a 4GB x86_64=20
>> machine :
>>
>> # dmesg | grep "TCP established hash"
>> TCP established hash table entries: 262144 (order: 10, 4194304 bytes=
)
>> # time cat /proc/net/tcp >/dev/null
>>
>> real    0m0.091s
>> user    0m0.001s
>> sys     0m0.090s
>=20
> As quoted above my idle x86_64, using the exact same hash table size,=
=20
> running 2.6.27-rc2.git1 uses 0.520 seconds for that same command, tha=
ts=20
> a difference of more then a factor 50 !!
>=20
> This is not about /proc/net/tcp not being fast, this is about it have=
n=20
> gotten slower by a factor of 50!
>=20
> Also notice that this slowdown does not happen on i386.

And your .config files on i386 and x86_64 are ?=20

Some configuration options can slow down all lock/unlock operations (CO=
NFIG_SMP, CONFIG_PREEMPT, CONFIG_PROVE_LOCKING, CONFIG_DEBUG_SPINLOCK, =
CONFIG_NR_CPUS ...)

If you TCP hash table has 512.000 slots (I am just guessing, you didnt =
provide this information), it can make a huge difference.=20

>=20
> Anyways I'll try 2.6.27-rc4 and report back with its results.
>=20

Yes, please, but nothing really changed in this area in the recent time=
s...

We added some checks so that softirqs can preempt us.
Latencies used to be very high, and are now bonded, at the price of pot=
ential slowdown for the /proc/net/tcp reader.




