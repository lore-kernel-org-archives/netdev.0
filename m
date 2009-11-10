From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 07/10] decnet: use RCU to find network devices
Date: Tue, 10 Nov 2009 20:25:18 +0100
Message-ID: <4AF9BE1E.7030702@gmail.com>
References: <20091110175446.280423729@vyatta.com>	<20091110175647.615305929@vyatta.com>	<4AF9B449.6040708@gmail.com> <20091110105053.16687e93@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Christine Caulfield <christine.caulfield@googlemail.com>,
	Hannes Eder <hannes@hanneseder.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Steven Whitehouse <swhiteho@redhat.com>,
	netdev@vger.kernel.org, linux-decnet-users@lists.sourceforge.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59129 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757591AbZKJTZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 14:25:25 -0500
In-Reply-To: <20091110105053.16687e93@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =C3=A9crit :
> On Tue, 10 Nov 2009 19:43:21 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> Stephen Hemminger a =C3=A9crit :
>>> When showing device statistics use RCU rather than read_lock(&dev_b=
ase_lock)
>>> Compile tested only.
>>>
>>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>>
>>> --- a/net/decnet/dn_dev.c	2009-11-10 09:30:55.557376454 -0800
>>> +++ b/net/decnet/dn_dev.c	2009-11-10 09:40:03.847005394 -0800
>>> @@ -856,9 +856,7 @@ int dn_dev_bind_default(__le16 *addr)
>>>  	dev =3D dn_dev_get_default();
>>>  last_chance:
>>>  	if (dev) {
>>> -		read_lock(&dev_base_lock);
>>>  		rv =3D dn_dev_get_first(dev, addr);
>>> -		read_unlock(&dev_base_lock);
>>>  		dev_put(dev);
>>>  		if (rv =3D=3D 0 || dev =3D=3D init_net.loopback_dev)
>>>  			return rv;
>>> @@ -1323,18 +1321,18 @@ static inline int is_dn_dev(struct net_d
>>
>> I dont understand this part. Why previous locking can be avoided ?
>=20
> dn_dev_get_default acquires a reference on dev so the device can
> not go away.
>=20
> It could be the original author meant to ensure the address list
> doesn't change. If so, then rtnl_lock() should have been used.

Hmm... I spot some bugs during my previous round of patches, so maybe
this is a real bug... We should double check.


