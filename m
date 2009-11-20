From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 06:42:41 +0100
Message-ID: <4B062C51.8090100@gmail.com>
References: <4B05D8DC.7020907@gmail.com>	 <412e6f7f0911191812uf0abc61w2f0d44f4d71bd55@mail.gmail.com>	 <4B0621FC.6060004@gmail.com>	 <412e6f7f0911192111jbc8b237sc619a54510219336@mail.gmail.com>	 <4B0627FA.3060103@gmail.com> <412e6f7f0911192134m24beca36m1887513513f130b8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47684 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753999AbZKTFmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 00:42:42 -0500
In-Reply-To: <412e6f7f0911192134m24beca36m1887513513f130b8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao a =C3=A9crit :
> On Fri, Nov 20, 2009 at 1:24 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> Changli Gao a =C3=A9crit :
>>
>> Please re-read my patch, you misunderstood it, or I dont get you.
>=20
> I think I didn't misunderstand it. If local socket only sends packets=
,
> which don't need replies from receiver, so new NIC RX IRQ, and NET_RX
> softirq won't be triggered. Who will call xps_flush() to free the
> memory used by locally generated packets?
>=20

Changli, when we transmit a skb on NIC, NIC is supposed to have a TX co=
mpletion
call back, to free this skb.

These completion calls are running from net_rx_action(), if driver is N=
API enabled.

Only NAPI enabled drivers are allowed to use XPS infrastructure.

I sent 100.000.000 packets in my pktgen+tg3 tests, without receiving a =
single packet
in return, I can tell you all packets were correctly freed :)


