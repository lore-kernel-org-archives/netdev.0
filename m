From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: restore skb->sk before pskb_trim() call
Date: Wed, 26 Apr 2017 18:14:51 +0200
Message-ID: <5900C77B.3030208@iogearbox.net>
References: <1493222963.6453.77.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53316 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934313AbdDZQO5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 12:14:57 -0400
In-Reply-To: <1493222963.6453.77.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/26/2017 06:09 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> While testing a fix [1] in ___pskb_trim(), addressing the WARN_ON_ONCE()
> in skb_try_coalesce() reported by Andrey, I found that we had an skb
> with skb->sk set but no skb->destructor.
>
> This invalidated heuristic found in commit 158f323b9868 ("net: adjust
> skb->truesize in pskb_expand_head()") and in cited patch.
>
> Considering the BUG_ON(skb->sk) we have in skb_orphan(), we should
> restrain the temporary setting to a minimal section.
>
> [1] https://patchwork.ozlabs.org/patch/755570/
>      net: adjust skb->truesize in ___pskb_trim()
>
> Fixes: 8f917bba0042 ("bpf: pass sk to helper functions")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: Andrey Konovalov <andreyknvl@google.com>

Good point, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
