From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [PATCH] veth: delay peer link configuration after interfaces are tied
Date: Mon, 30 May 2016 12:11:35 +0200
Message-ID: <878tyr4zzc.fsf@zoro.exoscale.ch>
References: <1464520637-19784-1-git-send-email-vincent@bernat.im>
	<574C0697.6060506@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:38673 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751137AbcE3KRw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 06:17:52 -0400
In-Reply-To: <574C0697.6060506@6wind.com> (Nicolas Dichtel's message of "Mon,
	30 May 2016 11:23:35 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 30 mai 2016 11:23 CEST, Nicolas Dichtel <nicolas.dichtel@6wi=
nd.com>=C2=A0:

>> @@ -466,6 +462,10 @@ static int veth_newlink(struct net *src_net, st=
ruct net_device *dev,
>> =20
>>  	priv =3D netdev_priv(peer);
>>  	rcu_assign_pointer(priv->peer, dev);
>> +
>> +	err =3D rtnl_configure_link(peer, ifmp);
>> +	if (err < 0)
>> +		goto err_configure_peer;

> You should fix the error path. 'unregister_netdevice(dev)' is missing=
=2E

I am sending another patch to fix that. I am quite unsure if I do the
right thing here.
--=20
Don't stop with your first draft.
            - The Elements of Programming Style (Kernighan & Plauger)
