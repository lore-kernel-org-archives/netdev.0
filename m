From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v3, kernel version 3.2.1] Source mode for macvlan interface
Date: Wed, 25 Jan 2012 07:22:43 +0100
Message-ID: <CAGsizzLHT6jK8zJn+5eJkTUt5NBdpK9uNHJTzDCPrbCcPBvBNA@mail.gmail.com>
References: <12446987.2261327416407141.JavaMail.root@5-MeO-DMT.ynet.sk>
 <25119746.2341327416953583.JavaMail.root@5-MeO-DMT.ynet.sk> <20120124.230354.1696063062900108959.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120124.230354.1696063062900108959.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/1/25 David Miller <davem@davemloft.net>:
> From: Stefan Gula <steweg@ynet.sk>
> Date: Tue, 24 Jan 2012 15:55:53 +0100 (CET)
>
>> diff -uprN -X linux/Documentation/dontdiff linux-3.2.1-orig/net/core=
/rtnetlink.c linux/net/core/rtnetlink.c
>> --- linux-3.2.1-orig/net/core/rtnetlink.c =A0 =A0 2012-01-12 20:42:4=
5.000000000 +0100
>> +++ linux/net/core/rtnetlink.c =A0 =A0 =A0 =A02012-01-24 14:26:58.08=
3219352 +0100
>> @@ -1506,6 +1506,9 @@ errout:
>>
>> =A0 =A0 =A0 if (send_addr_notify)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 call_netdevice_notifiers(NETDEV_CHANGEAD=
DR, dev);
>> + =A0 =A0 min_ifinfo_dump_size =3D max_t(u16, if_nlmsg_size(dev),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 min_ifinfo_dump_size);
>> +
>
> What is this? =A0And whatever it is why isn't it 1) described in the
> commit message and why isn't it 2) in a seperate patch if it's
> unrelated to this macvlan change?
>
> I'm not apply this patch as it is right now, it needs some sort of
> change.
>
It's a result of need to have enough space allocated for sk_buff
struct before called macvlan_fill_info. I know that it looks somehow
messy. BUt before the macvlan_fill_info is called there is only one
procedure calcit. The problem of calcit is that it doesn't have access
to struct net_device *dev int it. It has only access to struct sk_buff
*skb, so from that point it cannot be called directly (whole parsing
code had to be copied there to get the *dev a calling
if_nlmsg_size(dev) from it. On the other hand calcit returns global
static value of min_ifinfo_dump_size and that is shared among all
interfaces and modifying like this do the job properly. There was
another different way and that was creating and registering a whole
new PF_MACLVAN netlink group resulting in copying almost 95% percent
of given code and modified it somehow to do the same.

If it should be result of separate commitment than ok, but it was
result apparently of need only for use of macvlan that's why it was
included in my patch.

So how should I proceed with it?
