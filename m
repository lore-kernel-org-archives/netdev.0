From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Tue, 10 Nov 2009 20:14:09 +0800
Message-ID: <412e6f7f0911100414w7b6f45aap39f6568b7af2c1a7@mail.gmail.com>
References: <4AF924A5.1050303@gmail.com> <4AF92D6D.8060300@gmail.com>
	 <412e6f7f0911100143k68284faes92e39d8ca94aa9d4@mail.gmail.com>
	 <4AF9471C.5080606@gmail.com>
	 <412e6f7f0911100314i33d6a49dl5163b5e8472babcf@mail.gmail.com>
	 <4AF95174.3060104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:48634 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220AbZKJMOE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 07:14:04 -0500
Received: by pzk26 with SMTP id 26so2796193pzk.4
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 04:14:09 -0800 (PST)
In-Reply-To: <4AF95174.3060104@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2009 at 7:41 PM, Patrick McHardy <kaber@trash.net> wrot=
e:
> Changli Gao wrote:
>> 2009/11/10 Eric Dumazet <eric.dumazet@gmail.com>:
>>
>> The whole ifb.c file is attached, please review and test it. Thanks!
>
>> /* Number of TX queues per ifb */
>> static int numtxqs =3D 1;
>> module_param(numtxqs, int, 0444);
>> MODULE_PARM_DESC(numtxqs, "Number of TX queues per ifb");
>
> Module parameters suck as a configuration API. The existing numifbs
> option exists purely for compatibility reasons, I'd prefer if you'd
> this to the netlink interface.

How to do that? I haven't found any examples. Is there a interface to
config the number of the TX queues of a NIC.

>
>> static int __init ifb_init_one(int index)
>> {
>> =C2=A0 =C2=A0 =C2=A0 struct net_device *dev_ifb;
>> =C2=A0 =C2=A0 =C2=A0 int err;
>>
>> =C2=A0 =C2=A0 =C2=A0 dev_ifb =3D alloc_netdev_mq(sizeof(struct ifb_p=
rivate) * numtxqs, "ifb%d",
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ifb_setup, numtxqs);
>>
>
> This won't work for the rtnl_link setup since the size must
> be constant.
>

Does this work?

        ifb_link_ops.priv_size =3D sizeof(struct ifb_private) * numtxqs=
;
        rtnl_lock();
        err =3D __rtnl_link_register(&ifb_link_ops);

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
