From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Sun, 04 Nov 2007 22:23:10 +0100
Message-ID: <472E383E.7080004@cosmosbay.com>
References: <4729A774.9030409@cosmosbay.com>	<200711040018.15027.ak@suse.de> <20071103.162337.83099185.davem@davemloft.net> <472DAD90.4050709@cosmosbay.com> <472E0857.4080405@o2.pl> <472E0C24.9040009@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ak@suse.de,
	netdev@vger.kernel.org, acme@redhat.com
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:44905 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbXKDVXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2007 16:23:34 -0500
In-Reply-To: <472E0C24.9040009@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski a =E9crit :
> Jarek Poplawski wrote, On 11/04/2007 06:58 PM:
>=20
>> Eric Dumazet wrote, On 11/04/2007 12:31 PM:
>=20
> ...
>=20
>>> +static inline int inet_ehash_locks_alloc(struct inet_hashinfo *has=
hinfo)
>>> +{
>=20
> ...
>=20
>>> +	if (sizeof(rwlock_t) !=3D 0) {
>=20
> ...
>=20
>>> +		for (i =3D 0; i < size; i++)
>>> +			rwlock_init(&hashinfo->ehash_locks[i]);
>>
>> This looks better now, but still is doubtful to me: even if it's saf=
e with
>> current rwlock implementation, can't we imagine some new debugging o=
r
>> statistical code added, which would be called from rwlock_init() wit=
hout
>> using rwlock_t structure? IMHO, if read_lock() etc. are called in su=
ch a
>> case, rwlock_init() should be done as well.
>=20
>=20
> Of course I mean: if sizeof(rwlock_t) =3D=3D 0.

Given those two choices :

#if defined(CONFIG_SMP) || defined(CONFIG_PROVE__LOCKING)
     kmalloc(sizeof(rwlock_t) * size);
#endif

and

    if (sizeof(rwlock_t) !=3D 0) {
        kmalloc(sizeof(rwlock_t) * size);
    }

I prefer the 2nd one. Less error prone, and no need to remember how are=
=20
spelled the gazillions CONFIG_something we have.


