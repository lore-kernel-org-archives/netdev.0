From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix bogus RTT on special retransmission
Date: Fri, 28 Feb 2014 17:13:42 -0800
Message-ID: <1393636422.26794.91.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393634546-18802-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	nanditad@google.com, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:48537 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbaCABNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 20:13:54 -0500
Received: by mail-pd0-f182.google.com with SMTP id g10so1419735pdj.41
        for <netdev@vger.kernel.org>; Fri, 28 Feb 2014 17:13:54 -0800 (PST)
In-Reply-To: <1393634546-18802-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-28 at 16:42 -0800, Yuchung Cheng wrote:
> RTT may be bogus with tall loss probe (TLP) when a packet
> is retransmitted and latter (s)acked without TCPCB_SACKED_RETRANS flag.
> 
> For example, TLP calls __tcp_retransmit_skb() instead of
> tcp_retransmit_skb(). The skb timestamps are updated but the sacked
> flag is not marked with TCPCB_SACKED_RETRANS. As a result we'll
> get bogus RTT in tcp_clean_rtx_queue() or in tcp_sacktag_one() on
> spurious retransmission.
> 
> The fix is to apply the sticky flag TCP_EVER_RETRANS to enforce Karn's
> check on RTT sampling. However this will disable F-RTO if timeout occurs
> after TLP, by resetting undo_marker in tcp_enter_loss(). We relax this
> check to only if any pending retransmists are still in-flight.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
