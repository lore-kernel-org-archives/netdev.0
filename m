From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net-next 1/3] tcp: use TCP_SKB_CB(skb)->tcp_flags in
 input path
Date: Mon, 15 Sep 2014 12:13:30 -0400
Message-ID: <CADVnQykSrxg3NU+F7gwxT+RaLMCtGsPMQhhFg=1EpUsb5to8MQ@mail.gmail.com>
References: <1410779993-31464-1-git-send-email-edumazet@google.com>
	<1410779993-31464-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:35373 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750AbaIOQNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 12:13:34 -0400
Received: by mail-qg0-f45.google.com with SMTP id j107so4134363qga.32
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 09:13:30 -0700 (PDT)
In-Reply-To: <1410779993-31464-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 7:19 AM, Eric Dumazet <edumazet@google.com> wrote:
> Input path of TCP do not currently uses TCP_SKB_CB(skb)->tcp_flags,
> which is only used in output path.
>
> tcp_recvmsg(), looks at tcp_hdr(skb)->syn for every skb found in receive queue,
> and its unfortunate because this bit is located in a cache line right before
> the payload.
>
> We can simplify TCP by copying tcp flags into TCP_SKB_CB(skb)->tcp_flags.
>
> This patch does so, and avoids the cache line miss in tcp_recvmsg()
>
> Following patches will
> - allow a segment with FIN being coalesced in tcp_try_coalesce()
> - simplify tcp_collapse() by not copying the headers.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
