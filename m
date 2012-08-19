From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] net: tcp: move sk_rx_dst_set call after
 tcp_create_openreq_child()
Date: Sun, 19 Aug 2012 15:41:15 +0200
Message-ID: <1345383675.5158.202.camel@edumazet-glaptop>
References: <1345383038-8330-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:33169 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743Ab2HSNlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 09:41:20 -0400
Received: by wicr5 with SMTP id r5so3005591wic.1
        for <netdev@vger.kernel.org>; Sun, 19 Aug 2012 06:41:19 -0700 (PDT)
In-Reply-To: <1345383038-8330-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-08-19 at 09:30 -0400, Neal Cardwell wrote:
> This commit removes the sk_rx_dst_set calls from
> tcp_create_openreq_child(), because at that point the icsk_af_ops
> field of ipv6_mapped TCP sockets has not been set to its proper final
> value.
> 
> Instead, to make sure we get the right sk_rx_dst_set variant
> appropriate for the address family of the new connection, we have
> tcp_v{4,6}_syn_recv_sock() directly call the appropriate function
> shortly after the call to tcp_create_openreq_child() returns.
> 
> This also moves inet6_sk_rx_dst_set() to avoid a forward declaration
> with the new approach.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Reported-by: Artem Savkov <artem.savkov@gmail.com>
> Cc: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv4/tcp_ipv4.c      |    1 +
>  net/ipv4/tcp_minisocks.c |    2 --
>  net/ipv6/tcp_ipv6.c      |   25 +++++++++++++------------
>  3 files changed, 14 insertions(+), 14 deletions(-)

Thanks Neal !

Acked-by: Eric Dumazet <edumazet@google.com>
