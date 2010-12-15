From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 4/5 v2] ifb: add multiqueue support
Date: Wed, 15 Dec 2010 08:20:58 +0800
Message-ID: <AANLkTikucnTO_+g2Fa=ZoMFQYbeiQSvqkJURF254So6d@mail.gmail.com>
References: <1292340098-25537-1-git-send-email-xiaosuo@gmail.com> <1292342358.5934.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:39103 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757482Ab0LOAVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 19:21:20 -0500
Received: by fxm18 with SMTP id 18so1428661fxm.2
        for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 16:21:18 -0800 (PST)
In-Reply-To: <1292342358.5934.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 14, 2010 at 11:59 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>
> There is a problem here.
>
> You should sum in the loop rx_counters only, (the counters syncp
> protected), and use dev_txq_stats_fold() to get the tx_counters from
> core network.

Hmm, in ifb, txq->tx_counters aren't used in ifb_xmit() but
ri_tasklet(). IOW, rx and tx are reversed. Here I use txq->tx_counters
to reduce duplicate counters in ifb_q_private. Unless these variables
might be accessed outside of ifb, I can use them freely? Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
