From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [patch net-next-2.6 1/6] af_packet: use skb->skb_iif instead of orig_dev->ifindex
Date: Mon, 14 Mar 2011 23:10:45 +0800
Message-ID: <AANLkTikTNH3Lux-rusmtf0Xca=s0wtNzy8N4OxPjnO21@mail.gmail.com>
References: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
 <1299935679-18135-2-git-send-email-jpirko@redhat.com> <AANLkTimkUQ7JPAozRWnYgfwGu5wqeY-ikfdmWEGeUkrK@mail.gmail.com>
 <20110314065454.GA2751@psychotron.redhat.com> <AANLkTik6-qCHW-5vRUY4BdXJL1jVFsD85rTRWucUdkRe@mail.gmail.com>
 <20110314074342.GB2751@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62889 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176Ab1CNPNq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 11:13:46 -0400
Received: by fxm17 with SMTP id 17so2994612fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 08:13:45 -0700 (PDT)
In-Reply-To: <20110314074342.GB2751@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2011 at 3:43 PM, Jiri Pirko <jpirko@redhat.com> wrote:
> Mon, Mar 14, 2011 at 07:59:39AM CET, xiaosuo@gmail.com wrote:
>>>
>>
>>1557 static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_d=
evice *dev)
>>....
>>
>>1571 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pt_prev) {
>>1572 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
deliver_skb(skb2, pt_prev, skb->dev);
>>1573 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
pt_prev =3D ptype;
>>1574 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
continue;
>>1575 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>...
>>1603 =A0 =A0 =A0 =A0 }
>>1604 =A0 =A0 =A0 =A0 if (pt_prev)
>>1605 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pt_prev->func(skb2, skb->dev, pt=
_prev, skb->dev);
>>1606 =A0 =A0 =A0 =A0 rcu_read_unlock();
>>1607 }
>
> I'm probably missign something but I do not see the connection betwee=
n
> this and setting up sll->sll_ifindex in net/packet/af_packet.c
>

Think about a packet socket(with origdev set) for packets emitted via
NIC eth0, and sll->sll_ifindex is eth0->ifindex, but after your patch,
sll->sll_ifindex may be ZERO or the ifindex of the RX NIC for the
forwarded packets. However, I don't know if this origdev usage is
valid. Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
