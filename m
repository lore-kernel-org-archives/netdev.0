From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Tue, 10 Nov 2009 20:37:02 +0800
Message-ID: <412e6f7f0911100437g2759eb6dg509af4edb8848291@mail.gmail.com>
References: <4AF924A5.1050303@gmail.com> <4AF92D6D.8060300@gmail.com>
	 <412e6f7f0911100143k68284faes92e39d8ca94aa9d4@mail.gmail.com>
	 <4AF9471C.5080606@gmail.com>
	 <412e6f7f0911100314i33d6a49dl5163b5e8472babcf@mail.gmail.com>
	 <4AF95174.3060104@trash.net>
	 <412e6f7f0911100414w7b6f45aap39f6568b7af2c1a7@mail.gmail.com>
	 <4AF95A3D.5060602@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:63455 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669AbZKJMg4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 07:36:56 -0500
Received: by pzk26 with SMTP id 26so2806767pzk.4
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 04:37:02 -0800 (PST)
In-Reply-To: <4AF95A3D.5060602@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2009 at 8:19 PM, Patrick McHardy <kaber@trash.net> wrot=
e:
>
> You have to add a get_tx_queues() callback to the rtnl_link_ops.

It is used to get the current real_num_tx_queues and num_tx_queues,
not to setting.

> Additionally you need a new attribute (IFLA_NTXQ or something like
> that) that contains the number of queues. The callback has to parse
> the attribute and set the number of queues accordingly.

It seems another patch is needed first.

>> Does this work?
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 ifb_link_ops.priv_size =3D sizeof(struct=
 ifb_private) * numtxqs;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 rtnl_lock();
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D __rtnl_link_register(&ifb_link_o=
ps);
>
> Only for the module parameter. For rtnl_link you need to either
> allocate the private space seperately or turn priv_size into
> a callback that returns the required space based on the number
> of queues.

Do you means that if module ifb is loaded automatically, parameters
won't be set correctly?

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
