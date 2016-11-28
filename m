From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] sit: Set skb->protocol properly in
 ipip6_tunnel_xmit()
Date: Mon, 28 Nov 2016 10:17:23 -0800
Message-ID: <1480357043.18162.70.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161128.114703.154301432767947066.davem@davemloft.net>
         <1480352023.18162.63.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480354467.18162.66.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161128.130142.1225482479870737422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, sfr@canb.auug.org.au, elicooper@gmx.com,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35539 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754068AbcK1SSZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 13:18:25 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so13775392pga.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 10:18:25 -0800 (PST)
In-Reply-To: <20161128.130142.1225482479870737422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-28 at 13:01 -0500, David Miller wrote:

> Hmmm, ip6_finish_output2() also does a proper assignment of skb->protocol,
> therefore why was commit ae148b085876fa771d9ef2c05f85d4b4bf09ce0d
> ("ip6_tunnel: Update skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit()")
> necessary at all?
I was referring to Stephen bug report.

It appears that Eli changelog was not very precise, because his bug was
because of XFRM being involved.

xfrm_output() -> xfrm_output_gso() -> skb_gso_segment()

So XFRM calls skb_gso_segment() before ip_output() or
ip6_finish_output2() had a chance to change skb->protocol
