From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] tcpdump may trace some outbound packets twice.
Date: Tue, 16 May 2006 03:17:59 +0200
Message-ID: <44692847.4080100@trash.net>
References: <E1FfnZP-0003St-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, shemminger@osdl.org,
	ranjitm@google.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33256 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750962AbWEPBSB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 21:18:01 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FfnZP-0003St-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> David S. Miller <davem@davemloft.net> wrote:
> 
>>Other implementation possibility suggestions welcome :-)
> 
> 
> I see two possibilities:
> 
> 1) Move the af_packet hook into the NIC driver.
> 2) Rethink the lockless tx setup.  If all NICs followed the tg3 and
>    replaced spin_lock_irqsave with spin_lock then we should be able
>    to go back to just using the xmit_lock.

3) Clone the skb and have dev_queue_xmit_nit() consume it.

That should actually be pretty easy.
