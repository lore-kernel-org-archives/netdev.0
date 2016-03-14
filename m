From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 08/13] net/mlx5e: Add fragmented memory support
 for RX multi packet WQE
Date: Mon, 14 Mar 2016 13:23:07 -0700
Message-ID: <1457986987.31401.6.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
	 <1457703594-9482-9-git-send-email-saeedm@mellanox.com>
	 <1457706771.2663.37.camel@edumazet-ThinkPad-T530>
	 <CALzJLG_XU-KMp8dMqcNOpu1OxZRnJro4LFQohK=FLX+5uJKXpQ@mail.gmail.com>
	 <1457726319.2663.50.camel@edumazet-ThinkPad-T530>
	 <CALzJLG9rB4iBnOC0f+8NopjdS407-WJ9b7KFUPO9hjbwFCyP-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33523 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753263AbcCNUXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 16:23:19 -0400
Received: by mail-pa0-f54.google.com with SMTP id fl4so163694003pad.0
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 13:23:19 -0700 (PDT)
In-Reply-To: <CALzJLG9rB4iBnOC0f+8NopjdS407-WJ9b7KFUPO9hjbwFCyP-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-14 at 20:16 +0200, Saeed Mahameed wrote:

> we can do special accounting for ooo like issues in the stack (maybe
> count page references and sum up page sizes as you suggest), device
> drivers shouldn't have special handling/accounting to protect against
> such cases.

The existing skb->truesize is doing this already.

The fact that some drivers use PAGE_SIZE/2 instead of PAGE_SIZE is an
heuristic that is mostly okay, and we accept the risk :

Even if a smart attack is happening, host will consume 200 XB instead o=
f
100 XB.

But pretending to use 128 bytes is simply a dangerous weapon over your
head, since you end up consuming 1600 XB.

With tcp_mem[2] being 18% of physical memory, you end up consuming all
physical memory and crash.

I can tell you that these kind of attacks are very real. I=C2=B4ve seen=
 them
in action.
