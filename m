From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: RE: [PATCH net-next] mlx4: use dev_kfree_skb() instead of
 dev_kfree_skb_any()
Date: Thu, 20 Sep 2012 07:03:56 +0000
Message-ID: <953B660C027164448AE903364AC447D28721D307@MTLDAG01.mtl.com>
References: <1347866974.26523.53.camel@edumazet-glaptop>
	<953B660C027164448AE903364AC447D28721B46E@MTLDAG01.mtl.com>
	<1348056777.26523.750.camel@edumazet-glaptop>
 <CAL1qit_pkQ7YBzcAPMSWF4zeFS6yFj18P1yJMvj_Z-7SRMxeRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Or Gerlitz" <ogerlitz@mellanox.com>
To: Ying Cai <ycai@google.com>, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:34956 "HELO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751129Ab2ITHGM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2012 03:06:12 -0400
In-Reply-To: <CAL1qit_pkQ7YBzcAPMSWF4zeFS6yFj18P1yJMvj_Z-7SRMxeRg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ying,
 
> It seems all the TxQs are sharing the same interrupt for Tx
> completions. Will it be better to have separate interrupt per
> num_tx_rings_p_up (8) queues? E.g. for a 16 core system, with 16 * 8
> Tx queues, to have 16 interrupts for Tx completions of those 128 Tx
> queues?

Actually not all TxQs share same interrupt vector.
In commit 76532d0c we assigned an interrupt vector for each TX ring.
When the number of Queues is higher than number of interrupt vectors, there are queues that share interrupts
And actually reaching the assignment you specified.

> 
> Also I'm looking at mlx4_en_select_queue(), it is using
> __skb_tx_hash(). Use something to achieve XPS may bring better
> performances.
> 

We are considering this change. 
