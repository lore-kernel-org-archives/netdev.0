From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 2/2] ipv6: fix ip6_tnl_parse_tlv_enc_lim()
Date: Mon, 23 Jan 2017 16:06:18 -0800
Message-ID: <CANn89iKmt2hKOuastFw5Qc4qL7wFVk==kSP3bP0h8rfbS4_rCg@mail.gmail.com>
References: <20170123235804.29342-1-edumazet@google.com> <20170123235804.29342-3-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:34760 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751930AbdAXAGY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 19:06:24 -0500
Received: by mail-io0-f178.google.com with SMTP id l66so123365729ioi.1
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 16:06:19 -0800 (PST)
In-Reply-To: <20170123235804.29342-3-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 3:58 PM, Eric Dumazet <edumazet@google.com> wrote:
> This function suffers from multiple issues.
>
> First one is that pskb_may_pull() may reallocate skb->head,
> so the 'raw' pointer needs either to be reloaded or not used at all.
>
> Second issue is that NEXTHDR_DEST handling does not validate
> that the options are present in skb->data, so we might read
> garbage or access non existent memory.
>
> With help from Willem de Bruijn.

Hmm, I've added a bug. Will send a V2, sorry for this.
