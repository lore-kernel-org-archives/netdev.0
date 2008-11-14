From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH v3] net: #ifdef inet_bind_bucket::ib_net
Date: Fri, 14 Nov 2008 07:21:13 +0100
Message-ID: <491D18D9.1050708@cosmosbay.com>
References: <b6fcc0a0811131521h69419b4an102a0cee98841a83@mail.gmail.com> <491D003F.7060605@cosmosbay.com> <20081113.204025.162228911.davem@davemloft.net> <491D0482.1030706@cosmosbay.com> <20081114061452.GA2227@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:50270 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbYKNGVV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 01:21:21 -0500
In-Reply-To: <20081114061452.GA2227@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan a =E9crit :
> On Fri, Nov 14, 2008 at 05:54:26AM +0100, Eric Dumazet wrote:
>> David Miller a =E9crit :
>>> From: Eric Dumazet <dada1@cosmosbay.com>
>>> Date: Fri, 14 Nov 2008 05:36:15 +0100
>>>
>>>> This is better because :
>>>>
>>>> 1) No #ifdef CONFIG_NET_NS
>>>>
>>>> 2) The magic about &init_net is not duplicated in ten different in=
clude files, but
>>>>    centralized in the right file : include/net/net_namespace.h
>>> I %100 agree.
>> Speaking of those functions, what do you think of this one ?
>>
>> static inline
>> void dev_net_set(struct net_device *dev, struct net *net)
>> {
>> #ifdef CONFIG_NET_NS
>>        release_net(dev->nd_net);
>>        dev->nd_net =3D hold_net(net);
>> #endif
>> }
>>
>> I believe that its safer to hold a reference on "new" *before*
>> releasing reference on "old" object.
>>
>> Also, release_net() and hold_net() can be defined to do
>> the use_count refcounting regardless of CONFIG_NET_NS
>> (Its a different NETNS_REFCNT_DEBUG #ifdef)
>=20
> NETNS_REFCNT_DEBUG makes sense only with NET_NS=3Dy because init_net
> is never freed.

It makes sense when you want to debug things, without full NET_NS

Check CONFIG_PROVE_LOCKING or other debugging stuff

CONFIG_SMP can be unset, still we are able to check spinlocks are
lock()/unlock() are correctly paired

>=20
>> Yet another example where read_pnet() and write_pnet()
>> are the right answer : Its cleaner and fixes *bugs*.
>=20
> pnet stuff by definition can't fix bugs :-)

It will, I bet it.

Cant you see difference between

#ifdef CONFIG_NET_NS
	ptr->net =3D expression;
#endif

and

write_pnet(&ptr->net, expression);

Answer : In the 2nd case, (expression) is evaluated.

In case its evaluation has side effects (like... refcounting), it makes=
 a huge difference.




