From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH] net: increase skb->users instead of skb_clone()
Date: Thu, 16 Dec 2010 22:05:01 +0800
Message-ID: <AANLkTikdYi-Cs=4UtjJx-X4bW+LSKTQBTcSv23NS2S+S@mail.gmail.com>
References: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Xinan Tang <xinan.tang@intel.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:61521 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755820Ab0LPOFD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 09:05:03 -0500
Received: by fxm18 with SMTP id 18so3289349fxm.2
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 06:05:02 -0800 (PST)
In-Reply-To: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 1:57 PM, Changli Gao <xiaosuo@gmail.com> wrote:
> In dev_queue_xmit_nit(), we have to clone skbs as we need to mangle s=
kbs,
> however, we don't need to clone skbs for all the packet_types.
>
> Except for the first packet_type, we increase skb->users instead of
> skb_clone().

Hi Changli,
Take af_packet for example, I can't see benefit from this patch.

> +static inline int deliver_skb(struct sk_buff *skb,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct packet_type *pt_prev,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct net_device *orig_dev)
> +{
> + =C2=A0 =C2=A0 =C2=A0 atomic_inc(&skb->users);
> + =C2=A0 =C2=A0 =C2=A0 return pt_prev->func(skb, skb->dev, pt_prev, o=
rig_dev);
> +}
The increment call will incur skb_shared() failure in packet_rcv.
In reality, packet_rcv has to clone this packet by itself.


Thanks

--=20
--Junchang
