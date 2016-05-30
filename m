From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [PATCH] veth: delay peer link configuration after interfaces are tied
Date: Mon, 30 May 2016 17:26:51 +0200
Message-ID: <87fusz36tg.fsf@zoro.exoscale.ch>
References: <1464520637-19784-1-git-send-email-vincent@bernat.im>
	<574C0697.6060506@6wind.com> <878tyr4zzc.fsf@zoro.exoscale.ch>
	<574C59F1.80403@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:40226 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932508AbcE3P0y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 11:26:54 -0400
In-Reply-To: <574C59F1.80403@6wind.com> (Nicolas Dichtel's message of "Mon, 30
	May 2016 17:19:13 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 30 mai 2016 17:19 CEST, Nicolas Dichtel <nicolas.dichtel@6wi=
nd.com>=C2=A0:

>>>>  	priv =3D netdev_priv(peer);
>>>>  	rcu_assign_pointer(priv->peer, dev);
>>>> +
>>>> +	err =3D rtnl_configure_link(peer, ifmp);
>>>> +	if (err < 0)
>>>> +		goto err_configure_peer;
>>=20
>>> You should fix the error path. 'unregister_netdevice(dev)' is missi=
ng.
>>=20
>> I am sending another patch to fix that. I am quite unsure if I do th=
e
>> right thing here.
>>=20
> A less intrusive fix is to call 'rtmsg_ifinfo(RTM_NEWLINK, peer, ~0U,
> GFP_KERNEL);' a the end of veth_newlink().

I did that at first. Maybe this would make more sense to do
that. Otherwise, the first message contains an iflink value that we
cannot resolve with just the received netlink messages (since the
information is in the next netlink message). "ip monitor" seems to be
able to get the info, but I suppose it does an additional
lookup.
--=20
Make sure every module hides something.
            - The Elements of Programming Style (Kernighan & Plauger)
