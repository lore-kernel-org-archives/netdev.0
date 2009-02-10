From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Subject: Re: [PATCH] netns: remove useless synchronize_net()
Date: Tue, 10 Feb 2009 17:48:26 +0100
Message-ID: <4991AFDA.8020704@dev.6wind.com>
References: <498ABDA2.5040603@dev.6wind.com>	<20090205.234520.149982266.davem@davemloft.net>	<498C403D.9040500@dev.6wind.com> <20090206.141026.85510254.davem@davemloft.net> <49919FD4.3000008@dev.6wind.com> <4991AE04.7020307@free.fr>
Reply-To: nicolas.dichtel@dev.6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:49326 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753763AbZBJQsi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Feb 2009 11:48:38 -0500
In-Reply-To: <4991AE04.7020307@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10.02.2009 17:40, Daniel Lezcano a =E9crit :
> Nicolas Dichtel wrote:
>> Le 06.02.2009 23:10, David Miller a =E9crit :
>>> From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
>>> Date: Fri, 06 Feb 2009 14:50:53 +0100
>>>
>>>> If namespace is destroyed after this function, then cleanup_net()
>>>> will ensure that nobody is looking at it
>>>
>>> Maybe, but you better get some opinions from the people who wrote
>>> and maintain the network namespace code before I can consider
>>> your change seriously.
>>>
>>> None of them responded to your patch posting, probably because
>>> you failed to CC: any of them.
>> Sorry, I forget to cc them, now it's done.
>> The thread can be found here:=20
>> http://marc.info/?l=3Dlinux-netdev&m=3D123382930115535&w=3D2
>>
>> So, I'm waiting for maintainers's opinions.
> We can move one network device from one namespace to another namespac=
e,=20
> and that do not necessarily implies the network namespace will die an=
d=20
> call cleanup_net.
> Without synchronize_net, it would be possible to have netif_receive_s=
kb=20
> and dev_change_net_namespace to be executed concurrently, no ?
> Wouldn't the execution of one of this function be problematic if we a=
re=20
> in the delivery of a packet to the upper protocol in the big=20
> rcu_read_lock section of netif_receive_skb ?
Just to be sure: there is two synchronize_net() in dev_change_net_names=
pace(),=20
and I was talking about the second one. The second one is called just b=
efore=20
exiting the function.


Regards,
Nicolas

>=20
>    dev_shutdown(dev);
>=20
>    /* Notify protocols, that we are about to destroy
>       this device. They should clean all the things.
>    */
>    call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
>=20
>    /*
>     *    Flush the unicast and multicast chains
>     */
>    dev_addr_discard(dev);
>=20
>    netdev_unregister_kobject(dev);
>=20
>    /* Actually switch the network namespace */
>    dev_net_set(dev, net);
>=20
>=20
> Thanks
>  -- Daniel
>=20
