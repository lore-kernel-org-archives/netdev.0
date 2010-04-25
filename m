From: Piotr Hosowicz <piotr@hosowicz.com>
Subject: Re: [2.6.34-rc5-git6] EIP: is at inet6_csk_bind_conflict + 06xe/0xb7
 	[ipv6]
Date: Sun, 25 Apr 2010 19:01:50 +0200
Message-ID: <4BD4757E.8020503@example.com>
References: <l2z2d0a357f1004250811w6da355ebp95d1730473026c22@mail.gmail.com>	 <4BD45E68.4080900@example.com>	 <g2z2d0a357f1004250931pf5880c60l32fd0643e0f14bde@mail.gmail.com>	 <4BD46F9C.5060500@example.com>	 <1272213597.2069.32.camel@edumazet-laptop> <j2p2d0a357f1004250955i59969a2cp9fd9eb9f3ef22d4b@mail.gmail.com>
Reply-To: piotr@hosowicz.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sedat Dilek <sedat.dilek@googlemail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jiri Olsa <jolsa@redhat.com>,
	Jongman Heo <jongman.heo@gmail.com>
To: sedat.dilek@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <j2p2d0a357f1004250955i59969a2cp9fd9eb9f3ef22d4b@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25.04.2010 18:55, Sedat Dilek wrote:
> Rebuild ipv6 kernel-modules by:
>
> $ make M=3Dnet/ipv6
>
> ...and copied net/ipv6/*.ko and net/ipv6/netfilter/*.ko files manuall=
y
> to the right place.
>
> Applied your patch (seen on netdev ML) already and booted into new ke=
rnel.
> Works, thanks.
>
> Tested-by: Sedat Dilek<sedat.dilek@gmail.com>
>
> - Sedat -
>
> On Sun, Apr 25, 2010 at 6:39 PM, Eric Dumazet<eric.dumazet@gmail.com>=
  wrote:
>> Le dimanche 25 avril 2010 =C3=A0 18:36 +0200, Piotr Hosowicz a =C3=A9=
crit :
>>> On 25.04.2010 18:31, Sedat Dilek wrote:
>>>> [ CCing netdev ML ]
>>>>
>>>> Confirmed: The revert-patch [1] fixes the problem here.
>>>
>>> I confirm, I've built a git6 kernel and it works fine.
>>>
>>>> See also "Bug 15847 -  crash in inet6_csk_bind_conflict" [2].
>>>>
>>>> Feel free to add a... Tested-by: Sedat Dilek<sedat.dilek@gmail.com=
>
>>>
>>> I added created and tested phrase in my archive. ;-) Thank you a lo=
t. I
>>> hope there will be no this error in git7.
>>>
>>
>> Did you test the proposed fix ?

Eric, but where to get the proposed fix as a patch? I looked at kernel'=
s=20
bugzilla and there is no such thing. As for now I applied Sedat's=20
reverse patch and now I am booted fine in git6 kernel.

Regards,

Piotr Hosowicz

>> [PATCH] ipv6: Fix inet6_csk_bind_conflict()
>>
>> Commit fda48a0d7a84 (tcp: bind() fix when many ports are bound)
>> introduced a bug on IPV6 part.
>> We should not call ipv6_addr_any(inet6_rcv_saddr(sk2)) but
>> ipv6_addr_any(inet6_rcv_saddr(sk)) because sk2 can be IPV4, while sk=
 is
>> IPV6.
>>
>> Reported-by: Michael S. Tsirkin<mst@redhat.com>
>> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
>> ---
>> diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_conne=
ction_sock.c
>> index b4b7d40..3a4d92b 100644
>> --- a/net/ipv6/inet6_connection_sock.c
>> +++ b/net/ipv6/inet6_connection_sock.c
>> @@ -48,7 +48,7 @@ int inet6_csk_bind_conflict(const struct sock *sk,
>>                              ipv6_rcv_saddr_equal(sk, sk2))
>>                                 break;
>>                         else if (sk->sk_reuse&&  sk2->sk_reuse&&
>> -                               !ipv6_addr_any(inet6_rcv_saddr(sk2))=
&&
>> +                               !ipv6_addr_any(inet6_rcv_saddr(sk))&=
&
>>                                 ipv6_rcv_saddr_equal(sk, sk2))
>>                                 break;
>>                 }
>>
>>
>>


--=20
"Bardzo fajna firma, tylko czasami nie p=C5=82aci. Do jej g=C5=82=C3=B3=
wnych
zalet nale=C5=BC=C4=85: ekspres ci=C5=9Bnieniowy (ale tylko na jednym z=
 pi=C4=99-
ter) oraz fajne widoki z salki konferencyjnej. No i jakie=C5=9B
p=C3=B3=C5=82 roku temu odesz=C5=82o 90% pracownik=C3=B3w dzia=C5=82u I=
T, ale mo=C5=BCe nie
mieli racji ;)"
NP: Chickenfoot - Soap On A Rope
NB: 2.6.34-rc5-git6
