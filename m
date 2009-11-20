From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 13:34:23 +0800
Message-ID: <412e6f7f0911192134m24beca36m1887513513f130b8@mail.gmail.com>
References: <4B05D8DC.7020907@gmail.com>
	 <412e6f7f0911191812uf0abc61w2f0d44f4d71bd55@mail.gmail.com>
	 <4B0621FC.6060004@gmail.com>
	 <412e6f7f0911192111jbc8b237sc619a54510219336@mail.gmail.com>
	 <4B0627FA.3060103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:43134 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015AbZKTFeR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 00:34:17 -0500
Received: by pwi3 with SMTP id 3so1882340pwi.21
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 21:34:24 -0800 (PST)
In-Reply-To: <4B0627FA.3060103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2009 at 1:24 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Changli Gao a =C3=A9crit :
>
> Please re-read my patch, you misunderstood it, or I dont get you.

I think I didn't misunderstand it. If local socket only sends packets,
which don't need replies from receiver, so new NIC RX IRQ, and NET_RX
softirq won't be triggered. Who will call xps_flush() to free the
memory used by locally generated packets?

>
> If xps_consume_skb(skb) is ever called (from one to XXX times),
> then we xps_flush() them, from net_rx_action()
>
> net_rx_action()
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0while (has_work) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0perform_napi_t=
hings(); // calls xps_consume_skb()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0xps_flush(); // post things to remote cpus=
, and dont leak memory
> }
>
> This net_rx_action() is same for forwarding and localy generated pack=
ets.
>



--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
