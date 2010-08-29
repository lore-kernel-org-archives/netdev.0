From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] net: reset ip_summed in skb_tunnel_rx()
Date: Sun, 29 Aug 2010 08:35:01 -0700
Message-ID: <AANLkTimnZDG7O3SxKPiZavw7dj+_OoR8bAq72U7Copjr@mail.gmail.com>
References: <20100820193835.GA6025@del.dom.local>
	<20100821074742.GA2367@del.dom.local>
	<1282377058.2636.12.camel@edumazet-laptop>
	<20100821080735.GA2409@del.dom.local>
	<4C725FCB.2000304@fs.uni-ruse.bg>
	<20100823124736.GA16966@ff.dom.local>
	<1282568443.2486.34.camel@edumazet-laptop>
	<20100823131056.GA19160@ff.dom.local>
	<4C727B06.2060002@fs.uni-ruse.bg>
	<4C72802D.8090405@fs.uni-ruse.bg>
	<20100823141437.GA2282@del.dom.local>
	<4C734FB5.1090702@fs.uni-ruse.bg>
	<1282626102.2378.1351.camel@edumazet-laptop>
	<4C738636.4000107@fs.uni-ruse.bg>
	<4C73C8DF.4060601@fs.uni-ruse.bg>
	<1282662532.2477.248.camel@edumazet-laptop>
	<courier.4C74007C.00000EE4@fs.ru.acad.bg>
	<1282677599.2467.54.camel@edumazet-laptop>
	<4C74C0C4.5060102@fs.uni-ruse.bg>
	<1283068124.2277.230.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:58624 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539Ab0H2PfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Aug 2010 11:35:02 -0400
Received: by iwn5 with SMTP id 5so4160875iwn.19
        for <netdev@vger.kernel.org>; Sun, 29 Aug 2010 08:35:01 -0700 (PDT)
In-Reply-To: <1283068124.2277.230.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 29, 2010 at 12:48 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> It seems we forget to reset skb->ip_summed to CHECKSUM_NONE in various
> tunnels (gre, ipip, sit, ip6_tunnel), before re-entering stack.
>
> Add ip_summed initialization in skb_tunnel_rx(), and remove it from
> ipmr / ip6mr
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

This is intentional behavior.  For CHECKSUM_COMPLETE packets we
subtract off the checksum of the encapsulating headers that we remove
so we can still get the benefit of checksum hardware for the inner
packet as well.  GRE does this using skb_postpull_rcsum(), for IPIP it
is implicit because the outer IP header was already removed, etc.
