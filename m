From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 06:24:10 +0100
Message-ID: <4B0627FA.3060103@gmail.com>
References: <4B05D8DC.7020907@gmail.com>	 <412e6f7f0911191812uf0abc61w2f0d44f4d71bd55@mail.gmail.com>	 <4B0621FC.6060004@gmail.com> <412e6f7f0911192111jbc8b237sc619a54510219336@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50076 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbZKTFYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 00:24:11 -0500
In-Reply-To: <412e6f7f0911192111jbc8b237sc619a54510219336@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao a =C3=A9crit :
> You call xps_flush() in net_rx_aciton(). It means that if no new
> packet arrives, xps_flush() won't be called forever, and the memory
> used by skbs will be hold forever. Did I misunderstand? Your algorith=
m
> only works with packet forwarding but sending packets from local
> sockets.
>=20

Please re-read my patch, you misunderstood it, or I dont get you.

If xps_consume_skb(skb) is ever called (from one to XXX times),
then we xps_flush() them, from net_rx_action()

net_rx_action()
{
	while (has_work) {
		perform_napi_things(); // calls xps_consume_skb()
	}
	xps_flush(); // post things to remote cpus, and dont leak memory
}

This net_rx_action() is same for forwarding and localy generated packet=
s.
