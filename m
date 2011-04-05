From: Patrick McHardy <kaber@trash.net>
Subject: Re: Kernel panic nf_nat_setup_info+0x5b3/0x6e0
Date: Tue, 05 Apr 2011 13:49:51 +0200
Message-ID: <4D9B01DF.2050206@trash.net>
References: <118081298480841@web25.yandex.ru> <4D6E2BEB.50805@trash.net>	 <AANLkTikkz23221ZSiat8N5tnE_bkHN=1EUNQTDdnC30L@mail.gmail.com>	 <124481299095426@web67.yandex.ru>	 <AANLkTik87dd0=CqcMOcwKN-Hx7W6KD7A36DUhGAzLddr@mail.gmail.com>	 <AANLkTi=v_Ckn00N=b2R2pW7jb3BmyyWPSkeCYRxBW0CW@mail.gmail.com>	 <586191301580222@web107.yandex.ru> <1301582872.3169.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Oleg A. Arkhangelsky" <sysoleg@yandex.ru>,
	Changli Gao <xiaosuo@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1301582872.3169.44.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31.03.2011 16:47, Eric Dumazet wrote:
> Le jeudi 31 mars 2011 =E0 18:03 +0400, "Oleg A. Arkhangelsky" a =E9cr=
it :
>>
>> 26.03.2011, 16:44, "Changli Gao" <xiaosuo@gmail.com>:
>>> On Thu, Mar 3, 2011 at 3:33 PM, Changli Gao <xiaosuo@gmail.com>; wr=
ote:
>>>
>>>>  Please try the patch attached and test if the problem is solved o=
r not. Thanks.
>>>
>>> Any feedback? Thanks.
>>>
>>
>> Seems that patch is fine.
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D21512
>>
>=20
> I wonder if this is not hiding another bug.
>=20
> Adding an RCU grace period might reduce the probability window.
>=20
> By the time nf_conntrack_free(ct) is called, no other cpu/thread
> could/should use ct, or ct->ext ?
>=20
> Sure, another thread can find/pass_on ct in a lookup but should not u=
se
> it, since its refcount (ct_general.use) should be 0.
>=20
> Patrick ?

I think what's happening is that the conntrack entry is destroyed
and the NAT ct_extend destructor invoked, which removes the nat
extension from the RCU protected bysource hash, after which the
entire extension area is freed. Another CPU might still find the
old NAT entry with undefined contents in the hash though, so I
think using RCU to free the extension area is correct.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
