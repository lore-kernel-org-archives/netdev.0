From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fix problem in dequeuing from input_pkt_queue
Date: Fri, 21 May 2010 00:38:41 -0700 (PDT)
Message-ID: <20100521.003841.82805563.davem@davemloft.net>
References: <alpine.DEB.1.00.1005202101290.25742@pokey.mtv.corp.google.com>
	<1274424946.2439.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, xiaosuo@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32954
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753517Ab0EUHid convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 May 2010 03:38:33 -0400
In-Reply-To: <1274424946.2439.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 May 2010 08:55:46 +0200

> Le jeudi 20 mai 2010 =E0 21:37 -0700, Tom Herbert a =E9crit :
>> Fix some issues introduced in batch skb dequeuing for input_pkt_queu=
e.
>> The primary issue it that the queue head must be incremented only
>> after a packet has been processed, that is only after
>> __netif_receive_skb has been called.  This is needed for the mechani=
sm
>> to prevent OOO packet in RFS.  Also when flushing the input_pkt_queu=
e
>> and process_queue, the process queue should be done first to prevent
>> OOO packets.
>>=20
>> Because the input_pkt_queue has been effectively split into two queu=
es,
>> the calculation of the tail ptr is no longer correct.  The correct v=
alue
>> would be head+input_pkt_queue->len+process_queue->len.  To avoid
>> this calculation we added an explict input_queue_tail in softnet_dat=
a.
>> The tail value is simply incremented when queuing to input_pkt_queue=
=2E
>>=20
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
