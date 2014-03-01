From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: fix bogus RTT on special retransmission
Date: Fri, 28 Feb 2014 20:38:57 -0500
Message-ID: <CADVnQynxiJGzHdPisAN+YTYeoWQT1Cp2bJ4=0Zz=evu9cno5-Q@mail.gmail.com>
References: <1393634546-18802-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:46802 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbaCABi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 20:38:59 -0500
Received: by mail-ea0-f171.google.com with SMTP id n15so1621157ead.30
        for <netdev@vger.kernel.org>; Fri, 28 Feb 2014 17:38:57 -0800 (PST)
In-Reply-To: <1393634546-18802-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 28, 2014 at 7:42 PM, Yuchung Cheng <ycheng@google.com> wrote:
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

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
