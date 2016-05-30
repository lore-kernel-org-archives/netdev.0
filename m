From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] veth: delay peer link configuration after interfaces are
 tied
Date: Mon, 30 May 2016 17:19:13 +0200
Message-ID: <574C59F1.80403@6wind.com>
References: <1464520637-19784-1-git-send-email-vincent@bernat.im>
 <574C0697.6060506@6wind.com> <878tyr4zzc.fsf@zoro.exoscale.ch>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
To: Vincent Bernat <vincent@bernat.im>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35967 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933000AbcE3PTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 11:19:17 -0400
Received: by mail-wm0-f48.google.com with SMTP id n129so91368259wmn.1
        for <netdev@vger.kernel.org>; Mon, 30 May 2016 08:19:16 -0700 (PDT)
In-Reply-To: <878tyr4zzc.fsf@zoro.exoscale.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/05/2016 12:11, Vincent Bernat a =C3=A9crit :
>  =E2=9D=A6 30 mai 2016 11:23 CEST, Nicolas Dichtel <nicolas.dichtel@6=
wind.com> :
>=20
>>> @@ -466,6 +462,10 @@ static int veth_newlink(struct net *src_net, s=
truct net_device *dev,
>>> =20
>>>  	priv =3D netdev_priv(peer);
>>>  	rcu_assign_pointer(priv->peer, dev);
>>> +
>>> +	err =3D rtnl_configure_link(peer, ifmp);
>>> +	if (err < 0)
>>> +		goto err_configure_peer;
>=20
>> You should fix the error path. 'unregister_netdevice(dev)' is missin=
g.
>=20
> I am sending another patch to fix that. I am quite unsure if I do the
> right thing here.
>=20
A less intrusive fix is to call 'rtmsg_ifinfo(RTM_NEWLINK, peer, ~0U,
GFP_KERNEL);' a the end of veth_newlink().
