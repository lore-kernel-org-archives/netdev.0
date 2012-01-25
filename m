From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch v3, kernel version 3.2.1] Source mode for macvlan
 interface
Date: Wed, 25 Jan 2012 07:29:28 +0100
Message-ID: <1327472968.14373.41.camel@edumazet-laptop>
References: <12446987.2261327416407141.JavaMail.root@5-MeO-DMT.ynet.sk>
	 <25119746.2341327416953583.JavaMail.root@5-MeO-DMT.ynet.sk>
	 <20120124.230354.1696063062900108959.davem@davemloft.net>
	 <CAGsizzLHT6jK8zJn+5eJkTUt5NBdpK9uNHJTzDCPrbCcPBvBNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?UTF-8?Q?=C5=A0tefan?= Gula <steweg@ynet.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGsizzLHT6jK8zJn+5eJkTUt5NBdpK9uNHJTzDCPrbCcPBvBNA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 25 janvier 2012 =C3=A0 07:22 +0100, =C5=A0tefan Gula a =C3=A9=
crit :

> It's a result of need to have enough space allocated for sk_buff
> struct before called macvlan_fill_info. I know that it looks somehow
> messy. BUt before the macvlan_fill_info is called there is only one
> procedure calcit. The problem of calcit is that it doesn't have acces=
s
> to struct net_device *dev int it. It has only access to struct sk_buf=
f
> *skb, so from that point it cannot be called directly (whole parsing
> code had to be copied there to get the *dev a calling
> if_nlmsg_size(dev) from it. On the other hand calcit returns global
> static value of min_ifinfo_dump_size and that is shared among all
> interfaces and modifying like this do the job properly. There was
> another different way and that was creating and registering a whole
> new PF_MACLVAN netlink group resulting in copying almost 95% percent
> of given code and modified it somehow to do the same.
>=20
> If it should be result of separate commitment than ok, but it was
> result apparently of need only for use of macvlan that's why it was
> included in my patch.
>=20
> So how should I proceed with it?

A separate patch for this part, as David said ?

The intent is to catch people attention on a particular point, instead
of unnoticed code in some huge unrelated patch.
