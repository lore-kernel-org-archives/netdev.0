From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH net] tcp: fix bogus RTT on special retransmission
Date: Sun, 2 Mar 2014 16:16:47 -0800
Message-ID: <CAB_+Fg6T1frq4Pq0t0Ge2q8=xOfhxEwXXGFfeLXE+G8=ys2fcQ@mail.gmail.com>
References: <1393634546-18802-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:65174 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbaCCAQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 19:16:48 -0500
Received: by mail-ob0-f173.google.com with SMTP id gq1so6111369obb.4
        for <netdev@vger.kernel.org>; Sun, 02 Mar 2014 16:16:48 -0800 (PST)
In-Reply-To: <1393634546-18802-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 28, 2014 at 4:42 PM, Yuchung Cheng <ycheng@google.com> wrote:
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

Acked-by: Nandita Dukkipati <nanditad@google.com>
