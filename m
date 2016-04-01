From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 3/8] tcp: use one bit in TCP_SKB_CB to mark
 ACK timestamps
Date: Fri, 01 Apr 2016 08:44:58 -0700
Message-ID: <1459525498.6473.279.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459523080-29329-1-git-send-email-soheil.kdev@gmail.com>
	 <1459523080-29329-4-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, willemb@google.com,
	edumazet@google.com, ycheng@google.com, ncardwell@google.com,
	kafai@fb.com, Soheil Hassas Yeganeh <soheil@google.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35260 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549AbcDAPpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 11:45:00 -0400
Received: by mail-pa0-f41.google.com with SMTP id td3so93322085pab.2
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 08:45:00 -0700 (PDT)
In-Reply-To: <1459523080-29329-4-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-01 at 11:04 -0400, Soheil Hassas Yeganeh wrote:
> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> Currently, to avoid a cache line miss for accessing skb_shinfo,
> tcp_ack_tstamp skips socket that do not have
> SOF_TIMESTAMPING_TX_ACK bit set in sk_tsflags. This is
> implemented based on an implicit assumption that the
> SOF_TIMESTAMPING_TX_ACK is set via socket options for the
> duration that ACK timestamps are needed.
> 
> To implement per-write timestamps, this check should be
> removed and replaced with a per-packet alternative that
> quickly skips packets missing ACK timestamps marks without
> a cache-line miss.
> 
> To enable per-packet marking without a cache line miss, use
> one bit in TCP_SKB_CB to mark a whether a SKB might need a
> ack tx timestamp or not. Further checks in tcp_ack_tstamp are not
> modified and work as before.

Acked-by: Eric Dumazet <edumazet@google.com>
