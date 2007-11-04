From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Mon, 05 Nov 2007 00:08:30 +0100
Message-ID: <472E50EE.2040801@o2.pl>
References: <4729A774.9030409@cosmosbay.com>	<200711040018.15027.ak@suse.de> <20071103.162337.83099185.davem@davemloft.net> <472DAD90.4050709@cosmosbay.com> <472E0857.4080405@o2.pl> <472E0C24.9040009@o2.pl> <472E383E.7080004@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ak@suse.de,
	netdev@vger.kernel.org, acme@redhat.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:51600 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753291AbXKDW6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Nov 2007 17:58:47 -0500
In-Reply-To: <472E383E.7080004@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote, On 11/04/2007 10:23 PM:

> Jarek Poplawski a =E9crit :
>> Jarek Poplawski wrote, On 11/04/2007 06:58 PM:
>>
>>> Eric Dumazet wrote, On 11/04/2007 12:31 PM:
>> ...
>>
>>>> +static inline int inet_ehash_locks_alloc(struct inet_hashinfo *ha=
shinfo)
>>>> +{
>> ...
>>
>>>> +	if (sizeof(rwlock_t) !=3D 0) {
>> ...
>>
>>>> +		for (i =3D 0; i < size; i++)
>>>> +			rwlock_init(&hashinfo->ehash_locks[i]);
>>> This looks better now, but still is doubtful to me: even if it's sa=
fe with
>>> current rwlock implementation, can't we imagine some new debugging =
or
>>> statistical code added, which would be called from rwlock_init() wi=
thout
>>> using rwlock_t structure? IMHO, if read_lock() etc. are called in s=
uch a
>>> case, rwlock_init() should be done as well.
>>
>> Of course I mean: if sizeof(rwlock_t) =3D=3D 0.
>=20
> Given those two choices :
>=20
> #if defined(CONFIG_SMP) || defined(CONFIG_PROVE__LOCKING)
>      kmalloc(sizeof(rwlock_t) * size);
> #endif
>=20
> and
>=20
>     if (sizeof(rwlock_t) !=3D 0) {
>         kmalloc(sizeof(rwlock_t) * size);
>     }
>=20
> I prefer the 2nd one. Less error prone, and no need to remember how a=
re=20
> spelled the gazillions CONFIG_something we have.


I've written it's better, too. But this could be improved yet (someday)=
,
I hope.

Thanks,
Jarek P.
