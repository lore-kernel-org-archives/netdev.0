From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] veth: Fix veth_dellink method
Date: Sat, 31 Oct 2009 10:43:11 +0100
Message-ID: <4AEC06AF.6010804@gmail.com>
References: <4AEA8F0F.4030100@gmail.com> <m1hbtgmqew.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60061 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932673AbZJaJnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Oct 2009 05:43:10 -0400
In-Reply-To: <m1hbtgmqew.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman a =E9crit :
> Eric Dumazet <eric.dumazet@gmail.com> writes:
>>
>> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
>> index ffb502d..9bed694 100644
>> --- a/drivers/net/veth.c
>> +++ b/drivers/net/veth.c
>> @@ -450,8 +450,8 @@ static void veth_dellink(struct net_device *dev,=
 struct list_head *head)
>>  	priv =3D netdev_priv(dev);
>>  	peer =3D priv->peer;
>> =20
>> -	unregister_netdevice(dev);
>> -	unregister_netdevice(peer);
>> +	unregister_netdevice_queue(dev, head);
>> +	unregister_netdevice_queue(peer, head);
>=20
> Unless I am mistaken you need to change the list_add_tail to
> list_move_tail in unregister_netdevice_queue because we will be
> adding each veth device twice.
>=20

You are right, and your patch is the solution to this problem

Thanks

