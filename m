From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sit: Set skb->protocol properly in
 ipip6_tunnel_xmit()
Date: Mon, 28 Nov 2016 15:06:52 -0500 (EST)
Message-ID: <20161128.150652.616103157114396212.davem@davemloft.net>
References: <1480354467.18162.66.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161128.130142.1225482479870737422.davem@davemloft.net>
        <1480357043.18162.70.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, sfr@canb.auug.org.au, elicooper@gmx.com,
        netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40200 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754093AbcK1UG5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:06:57 -0500
In-Reply-To: <1480357043.18162.70.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 28 Nov 2016 10:17:23 -0800

> It appears that Eli changelog was not very precise, because his bug was
> because of XFRM being involved.
> 
> xfrm_output() -> xfrm_output_gso() -> skb_gso_segment()
> 
> So XFRM calls skb_gso_segment() before ip_output() or
> ip6_finish_output2() had a chance to change skb->protocol

I think if we do it in ip6_local_out and ip_local_out, then none of
these hacks will be necessary at all.
