From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: increase skb->users instead of skb_clone()
Date: Thu, 16 Dec 2010 22:12:11 +0800
Message-ID: <AANLkTi=DvyuZeWzzi5WJR7AeTZba+U7Vz9cJYR5uRBVc@mail.gmail.com>
References: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com> <AANLkTikdYi-Cs=4UtjJx-X4bW+LSKTQBTcSv23NS2S+S@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Xinan Tang <xinan.tang@intel.com>, netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:48588 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753670Ab0LPOMc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 09:12:32 -0500
Received: by fxm18 with SMTP id 18so3296986fxm.2
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 06:12:31 -0800 (PST)
In-Reply-To: <AANLkTikdYi-Cs=4UtjJx-X4bW+LSKTQBTcSv23NS2S+S@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 10:05 PM, Junchang Wang <junchangwang@gmail.com=
> wrote:
>
> Hi Changli,
> Take af_packet for example, I can't see benefit from this patch.
>
>> +static inline int deliver_skb(struct sk_buff *skb,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct pac=
ket_type *pt_prev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct net=
_device *orig_dev)
>> +{
>> + =A0 =A0 =A0 atomic_inc(&skb->users);
>> + =A0 =A0 =A0 return pt_prev->func(skb, skb->dev, pt_prev, orig_dev)=
;
>> +}
> The increment call will incur skb_shared() failure in packet_rcv.
> In reality, packet_rcv has to clone this packet by itself.
>
>

This happens when run_filter returns non zero. For your case, only
small parts of packets match bpf filter.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
