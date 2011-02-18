From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: convert bonding to use rx_handler
Date: Fri, 18 Feb 2011 21:03:12 +0100
Message-ID: <20110218200311.GC2602@psychotron.redhat.com>
References: <20110218141456.GD2939@psychotron.redhat.com>
 <1298039252.6201.66.camel@edumazet-laptop>
 <4D5E8655.5070304@trash.net>
 <20110218145850.GF2939@psychotron.redhat.com>
 <4D5E953F.6010606@trash.net>
 <1298045670.6201.73.camel@edumazet-laptop>
 <20110218184725.GA2602@psychotron.redhat.com>
 <1298056657.2425.28.camel@edumazet-laptop>
 <20110218192856.GB2602@psychotron.redhat.com>
 <1298059106.2425.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	fubar@us.ibm.com, nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755064Ab1BRUFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 15:05:04 -0500
Content-Disposition: inline
In-Reply-To: <1298059106.2425.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Feb 18, 2011 at 08:58:26PM CET, eric.dumazet@gmail.com wrote:
>Le vendredi 18 f=E9vrier 2011 =E0 20:28 +0100, Jiri Pirko a =E9crit :
>
>> Yes I saw this. We would have to do something like:
>>=20
>> struct skb_rx_context {
>> 	struct sk_buff *skb;
>> 	struct net_device *orig_dev;
>> };
>>=20
>> static DEFINE_PER_CPU(struct skb_rx_context, skb_rx_context);
>>=20
>> and then in __netif_receive_skb():
>>=20
>> struct skb_rx_context *cont =3D __this_cpu_read(skb_rx_context);
>>=20
>> if (cont->skb !=3D skb) {
>> 	cont->skb =3D skb;
>> 	orig_dev =3D cont->orig_dev =3D skb->dev;
>> } else {
>> 	orig_dev =3D cont->orig_dev;
>> }
>>=20
>>=20
>> Does this make sense?
>
>Well, yes, something like that, but I think you dont need to keep a
>pointer to current skb. (It would not work if one handled/freed, same
>'skb pointer' is reused a bit later)

Well I think I need. How else should I distinguish that new skb (first
time in __netif_receive_skb) is there and I need to remember orig_dev?

>
>Sorry, I wont have time to look at this right now, its now 21h00 in
>France, time to get some time with family ;)

Np, same time here in CZ :)


>
>See you !
>
>
