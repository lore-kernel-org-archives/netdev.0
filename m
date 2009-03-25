From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6: Add 'autoconf' and 'disable_ipv6' module parameters
Date: Wed, 25 Mar 2009 07:51:24 -0400
Message-ID: <49CA1ABC.7000900@hp.com>
References: <> <1237945752-14362-1-git-send-email-brian.haley@hp.com> <49C99315.6070504@hp.com> <alpine.LNX.2.00.0903250526050.6682@firda.kolla.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brian Haley <brian.haley@hp.com>, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Kolbj=F8rn_Barmen?= <linux@kolla.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:39407 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756347AbZCYLv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 07:51:28 -0400
In-Reply-To: <alpine.LNX.2.00.0903250526050.6682@firda.kolla.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kolbj=F8rn Barmen wrote:
>=20
>> Also, it looks like if someone decides to switch IPv6 back on for a =
particular
>> interface, they would have to wait until the next RA to get an addre=
ss.  Not an
>> optimum solution.
>=20
> Isnt this the normal way anyways, or do new interfaces send some sort=
 of
> "I'm new here, give me a prefix and router announcement, please!" nor=
mally
> when they go online? If so, maybe that should be done here as well.
>=20

When the interface first comes up, it sends a Router Solicitation that =
triggers
the RA.


>>> @@ -1874,11 +1875,11 @@ void addrconf_prefix_rcv(struct net_device =
*dev, u8 *opt, int len)
>>> =20
>>>  	/* Try to figure out our local address for this prefix */
>>> =20
>>> -	if (pinfo->autoconf && in6_dev->cnf.autoconf) {
>>> +	if (pinfo->autoconf && in6_dev->cnf.autoconf &&
>>> +	    net->ipv6.devconf_all->autoconf) {
>>>  		struct inet6_ifaddr * ifp;
>>>  		struct in6_addr addr;
>>>  		int create =3D 0, update_lft =3D 0;
>>> -		struct net *net =3D dev_net(dev);
>>> =20
>>>  		if (pinfo->prefix_len =3D=3D 64) {
>>>  			memcpy(&addr, &pinfo->prefix, 8);
>>> @@ -4378,6 +4379,11 @@ static int addrconf_init_net(struct net *net=
)
>>>  		dflt =3D kmemdup(dflt, sizeof(ipv6_devconf_dflt), GFP_KERNEL);
>>>  		if (dflt =3D=3D NULL)
>>>  			goto err_alloc_dflt;
>>> +	} else {
>>> +		/* these will be inherited by all namespaces */
>>> +		all->autoconf =3D dflt->autoconf =3D ipv6_defaults.autoconf;
>>> +		all->disable_ipv6 =3D dflt->disable_ipv6 =3D
>>> +			ipv6_defaults.disable_ipv6;
>> Why set 'all'?  Since no interfaces are created yet, setting dflt ac=
complishes
>> what you want.
>=20
> How do you know that no interfaces are created? The IPv6 modules migh=
t not
> have been loaded on boot, but at a later stage.
>=20

Ah, but the IPv6 portions of the interface are created by the ipv6 modu=
le
when it loads.  At the addrconf_init_net() time, no interface are creat=
ed yet.

-vlad

