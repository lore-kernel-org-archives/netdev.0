From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next-2.6] net_sched: sch_sfq: better struct
 layouts
Date: Mon, 20 Dec 2010 21:33:46 -0800 (PST)
Message-ID: <20101220.213346.104060040.davem@davemloft.net>
References: <20101220.133342.246531313.davem@davemloft.net>
	<1292881372.2627.38.camel@edumazet-laptop>
	<1292885698.2627.119.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, jarkao2@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44295
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751239Ab0LUFdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 00:33:16 -0500
In-Reply-To: <1292885698.2627.119.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Dec 2010 23:54:58 +0100

> [PATCH v3 net-next-2.6] net_sched: sch_sfq: better struct layouts
> 
> This patch shrinks sizeof(struct sfq_sched_data)
> from 0x14f8 (or more if spinlocks are bigger) to 0x1180 bytes, and
> reduce text size as well.
> 
>    text    data     bss     dec     hex filename
>    4821     152       0    4973    136d old/net/sched/sch_sfq.o
>    4627     136       0    4763    129b new/net/sched/sch_sfq.o
> 
> 
> All data for a slot/flow is now grouped in a compact and cache friendly
> structure, instead of being spreaded in many different points.
> 
> struct sfq_slot {
>         struct sk_buff  *skblist_next;
>         struct sk_buff  *skblist_prev;
>         sfq_index       qlen; /* number of skbs in skblist */
>         sfq_index       next; /* next slot in sfq chain */
>         struct sfq_head dep; /* anchor in dep[] chains */
>         unsigned short  hash; /* hash value (index in ht[]) */
>         short           allot; /* credit for this slot */
> };
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
