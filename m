From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sit: Set skb->protocol properly in
 ipip6_tunnel_xmit()
Date: Mon, 28 Nov 2016 15:00:30 -0500 (EST)
Message-ID: <20161128.150030.370640725503436541.davem@davemloft.net>
References: <20161128.130142.1225482479870737422.davem@davemloft.net>
        <1480357043.18162.70.camel@edumazet-glaptop3.roam.corp.google.com>
        <1480357935.18162.76.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, sfr@canb.auug.org.au, elicooper@gmx.com,
        netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39944 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755011AbcK1UAj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:00:39 -0500
In-Reply-To: <1480357935.18162.76.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 28 Nov 2016 10:32:15 -0800

> On Mon, 2016-11-28 at 10:17 -0800, Eric Dumazet wrote:
> 
>> I was referring to Stephen bug report.
>> 
>> It appears that Eli changelog was not very precise, because his bug was
>> because of XFRM being involved.
>> 
>> xfrm_output() -> xfrm_output_gso() -> skb_gso_segment()
>> 
>> So XFRM calls skb_gso_segment() before ip_output() or
>> ip6_finish_output2() had a chance to change skb->protocol
> 
> So maybe the real fix would be to set skb->protocol at the right place,
> before xfrm can be called, instead of chasing all skb producers ;)

And the key for this would be dst_output() invocations.
