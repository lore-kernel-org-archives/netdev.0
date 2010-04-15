From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: fix softnet_stat
Date: Thu, 15 Apr 2010 11:08:47 +0800
Message-ID: <h2i412e6f7f1004142008s567de0c1racb27c4e24b11b57@mail.gmail.com>
References: <1271300513-9995-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.211.194]:55265 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756408Ab0DODJI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 23:09:08 -0400
Received: by ywh32 with SMTP id 32so466200ywh.33
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 20:09:07 -0700 (PDT)
In-Reply-To: <1271300513-9995-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 15, 2010 at 11:01 AM, Changli Gao <xiaosuo@gmail.com> wrote=
:
> fix softnet_stat
>
> Per cpu variable softnet_data.total was shared between IRQ and SoftIR=
Q context
> without any protection. And enqueue_to_backlog should update the netd=
ev_rx_stat
> of the target CPU.
>
> This patch changes the meaning of softnet_data.total to the number of=
 packets
> processed, not includes dropped, in order to avoid it sharing between=
 IRQ and
> SoftIRQ. And softnet_data.dropped is protected in the corresponding
> input_pkt_queue.lock, if RPS is enabled.
>

I forget a comment:

This patch also fixed a bug: packets received by enqueue_to_backlog()
was counted twice: one in enqueue_to_backlog(), and one in
__netif_receive_skb(), although they may not on the same CPUs.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
