From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [patch net-next-2.6 1/6] af_packet: use skb->skb_iif instead of orig_dev->ifindex
Date: Mon, 14 Mar 2011 14:59:39 +0800
Message-ID: <AANLkTik6-qCHW-5vRUY4BdXJL1jVFsD85rTRWucUdkRe@mail.gmail.com>
References: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
 <1299935679-18135-2-git-send-email-jpirko@redhat.com> <AANLkTimkUQ7JPAozRWnYgfwGu5wqeY-ikfdmWEGeUkrK@mail.gmail.com>
 <20110314065454.GA2751@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45041 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202Ab1CNHAA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 03:00:00 -0400
Received: by fxm17 with SMTP id 17so2599595fxm.19
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2011 23:59:59 -0700 (PDT)
In-Reply-To: <20110314065454.GA2751@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2011 at 2:54 PM, Jiri Pirko <jpirko@redhat.com> wrote:
> Mon, Mar 14, 2011 at 12:52:37AM CET, xiaosuo@gmail.com wrote:
>>On Sat, Mar 12, 2011 at 9:14 PM, Jiri Pirko <jpirko@redhat.com> wrote=
:
>>> Since skb_iif has the desired value (ifindex of physical device act=
ually
>>> received the traffic) use that instead.
>>>
>>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>> Reviewed-by: Changli Gao <xiaosuo@gmail.com>
>>> Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
>>> ---
>>
>>This may "break" the ptype handlers in TX path, as we always assign
>>skb->dev to origdev there. Thanks.
>
> Changli, would you please point me the relevant code?. Thanks!
>

1557 static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_dev=
ice *dev)
=2E...

1571                         if (pt_prev) {
1572                                 deliver_skb(skb2, pt_prev, skb->de=
v);
1573                                 pt_prev =3D ptype;
1574                                 continue;
1575                         }
=2E..
1603         }
1604         if (pt_prev)
1605                 pt_prev->func(skb2, skb->dev, pt_prev, skb->dev);
1606         rcu_read_unlock();
1607 }

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
