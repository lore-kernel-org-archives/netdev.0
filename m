From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH nf-next-2.6] xt_hashlimit: RCU conversion
Date: Thu, 01 Apr 2010 14:36:54 +0200
Message-ID: <4BB49366.4030001@trash.net>
References: <4BA74950.6000305@infopact.nl> <4BA7A5D8.5080101@trash.net>	 <4BA8DAC5.6050002@infopact.nl> <1269364893.2983.296.camel@edumazet-laptop>	 <4BAA2DC5.7000409@infopact.nl>  <1269447674.3213.64.camel@edumazet-laptop>	 <1269509574.3626.9.camel@edumazet-laptop>  <4BAB3C8B.3030104@trash.net>	 <1269514928.3626.13.camel@edumazet-laptop>	 <1270038210.2103.23.camel@edumazet-laptop>  <4BB47D81.3060400@trash.net> <1270123804.2229.91.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jorrit Kronjee <j.kronjee@infopact.nl>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1270123804.2229.91.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le jeudi 01 avril 2010 =E0 13:03 +0200, Patrick McHardy a =E9crit :
>>> -/* allocate dsthash_ent, initialize dst, put in htable and lock it=
 */
>>> -static struct dsthash_ent *
>>> -dsthash_alloc_init(struct xt_hashlimit_htable *ht,
>>> -		   const struct dsthash_dst *dst)
>> Is there a reason for moving this function downwards in the file?
>> That unnecessarily increases the diff and makes the patch harder to
>> review. For review purposes I moved it back up, resulting in 42
>> lines less diff.
>> --
>=20
> Well, this is because I had to move inside this function various
> initializations and these inits use user2credits() which was defined
> after dsthash_alloc_init().

I thought I also tried to compile it after my change, but apparently
I made some mistake :)

> But we can avoid this since we hold the entry spinlock, and before ha=
sh
> insertion.
>=20
> Only the lookup fields and the spinlock MUST be committed to memory
> before the insert. Other fields can be initialized later by caller.
>=20
> Here is V2 of patch, I added locking as well in dl_seq_real_show()
> because we call rateinfo_recalc(). htable main lock doesnt anymore
> protects each entry rateinfo.
>=20
> Thanks
>=20
> [PATCH nf-next-2.6] xt_hashlimit: RCU conversion
>=20
> xt_hashlimit uses a central lock per hash table and suffers from
> contention on some workloads. (Multiqueue NIC or if RPS is enabled)
>=20
> After RCU conversion, central lock is only used when a writer wants t=
o
> add or delete an entry.
>=20
> For 'readers', updating an existing entry, they use an individual loc=
k
> per entry.

Applied, thanks a lot Eric.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
