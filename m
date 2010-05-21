From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: fix problem in dequeuing from input_pkt_queue
Date: Fri, 21 May 2010 08:55:46 +0200
Message-ID: <1274424946.2439.7.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1005202101290.25742@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, xiaosuo@gmail.com, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:37988 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219Ab0EUGzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 02:55:50 -0400
Received: by wwi18 with SMTP id 18so435206wwi.19
        for <netdev@vger.kernel.org>; Thu, 20 May 2010 23:55:48 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1005202101290.25742@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 mai 2010 =C3=A0 21:37 -0700, Tom Herbert a =C3=A9crit :
> Fix some issues introduced in batch skb dequeuing for input_pkt_queue=
=2E
> The primary issue it that the queue head must be incremented only
> after a packet has been processed, that is only after
> __netif_receive_skb has been called.  This is needed for the mechanis=
m
> to prevent OOO packet in RFS.  Also when flushing the input_pkt_queue
> and process_queue, the process queue should be done first to prevent
> OOO packets.
>=20
> Because the input_pkt_queue has been effectively split into two queue=
s,
> the calculation of the tail ptr is no longer correct.  The correct va=
lue
> would be head+input_pkt_queue->len+process_queue->len.  To avoid
> this calculation we added an explict input_queue_tail in softnet_data=
=2E
> The tail value is simply incremented when queuing to input_pkt_queue.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


