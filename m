From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: pskb_copy() in tcp_transmit_skb()
Date: Tue, 13 Sep 2011 15:41:08 +0300
Message-ID: <201109131541.08542.christoph.paasch@uclouvain.be>
References: <201109131221.37561.christoph.paasch@uclouvain.be> <201109131355.55588.christoph.paasch@uclouvain.be> <CAL4Wiio=2MO2u53dvU1fqjeKqgQuVBmgDpZeVROMaZYcPPDpzA@mail.gmail.com>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gaofeng <gaofeng@cn.fujitsu.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:35057 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553Ab1IMMlO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 08:41:14 -0400
In-Reply-To: <CAL4Wiio=2MO2u53dvU1fqjeKqgQuVBmgDpZeVROMaZYcPPDpzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric,

On Tuesday 13 September 2011 wrote Eric Dumazet:
> I suggest you read dev_queue_xmit_nit() : Every xmit packet can be
> cloned right here.
>=20
> By the time tcp_retransmit_skb() is called, cloned skb might still be
> in a AF_PACKET queue (or even a device TX queue)

Thanks for the clear answer.

So, basically every call to tcp_retransmit_skb on an skb that is also s=
till=20
hold in an AF_PACKET queue will end up in pskb_copy, because:
1. it has been cloned previously in tcp_transmit_skb()
2. The data_ref > 1 because it's clone is still in an AF_PACKET queue.

Please correct me, if I'm wrong.

Christoph


--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=E9 Catholique de Louvain

www.rollerbulls.be
--
