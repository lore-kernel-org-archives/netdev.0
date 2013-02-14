From: =?ISO-8859-1?Q?Sebastian_P=F6hn?= <sebastian.poehn@googlemail.com>
Subject: tuntap: Overload handling
Date: Thu, 14 Feb 2013 12:50:30 +0100
Message-ID: <CAGUzgdJOLmOyd9dd=Ht-qgZ9B-or59pDwaUY28DrbnL4BKFPcw@mail.gmail.com>
References: <CAGUzgdK9U3hreLxtc6eP3CSpLsfhkn2ZKpFp9_VJhWr2gz0uCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:48995 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756997Ab3BNLub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 06:50:31 -0500
Received: by mail-pb0-f44.google.com with SMTP id wz12so138108pbc.31
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 03:50:31 -0800 (PST)
In-Reply-To: <CAGUzgdK9U3hreLxtc6eP3CSpLsfhkn2ZKpFp9_VJhWr2gz0uCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am having a look on the tun driver to realize an userspace network
driver ( TAP + UIO ). Maybe that's not the use-case tun is intended
for.

What I've noticed is that in tun.c Line 741

static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)

/* Limit the number of packets queued by dividing txq length with the
 * number of queues.
 */
if (skb_queue_len(&tfile->socket.sk->sk_receive_queue)
 >= dev->tx_queue_len / tun->numqueues)
goto drop;

If a frame can not be tx it is dropped by the driver.
Wouldn't it be more correct to netif_tx_stop_queue() so that packet
drops are performed by the overlying traffic control code?

Of course this is not very likely in virtual environments but as soon
as any real network hop is involved it could be important.

(I also had a look on some two year old version of tun.c. There
queue/tx stopping was done correctly.)

---
