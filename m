From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 1/6] af_packet: use skb->skb_iif instead of
 orig_dev->ifindex
Date: Mon, 14 Mar 2011 08:43:43 +0100
Message-ID: <20110314074342.GB2751@psychotron.redhat.com>
References: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
 <1299935679-18135-2-git-send-email-jpirko@redhat.com>
 <AANLkTimkUQ7JPAozRWnYgfwGu5wqeY-ikfdmWEGeUkrK@mail.gmail.com>
 <20110314065454.GA2751@psychotron.redhat.com>
 <AANLkTik6-qCHW-5vRUY4BdXJL1jVFsD85rTRWucUdkRe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28678 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754446Ab1CNHnx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 03:43:53 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTik6-qCHW-5vRUY4BdXJL1jVFsD85rTRWucUdkRe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 14, 2011 at 07:59:39AM CET, xiaosuo@gmail.com wrote:
>On Mon, Mar 14, 2011 at 2:54 PM, Jiri Pirko <jpirko@redhat.com> wrote:
>> Mon, Mar 14, 2011 at 12:52:37AM CET, xiaosuo@gmail.com wrote:
>>>On Sat, Mar 12, 2011 at 9:14 PM, Jiri Pirko <jpirko@redhat.com> wrot=
e:
>>>> Since skb_iif has the desired value (ifindex of physical device ac=
tually
>>>> received the traffic) use that instead.
>>>>
>>>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>>> Reviewed-by: Changli Gao <xiaosuo@gmail.com>
>>>> Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
>>>> ---
>>>
>>>This may "break" the ptype handlers in TX path, as we always assign
>>>skb->dev to origdev there. Thanks.
>>
>> Changli, would you please point me the relevant code?. Thanks!
>>
>
>1557 static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_de=
vice *dev)
>....
>
>1571                         if (pt_prev) {
>1572                                 deliver_skb(skb2, pt_prev, skb->d=
ev);
>1573                                 pt_prev =3D ptype;
>1574                                 continue;
>1575                         }
>...
>1603         }
>1604         if (pt_prev)
>1605                 pt_prev->func(skb2, skb->dev, pt_prev, skb->dev);
>1606         rcu_read_unlock();
>1607 }

I'm probably missign something but I do not see the connection between
this and setting up sll->sll_ifindex in net/packet/af_packet.c

>
>--=20
>Regards,
>Changli Gao(xiaosuo@gmail.com)
