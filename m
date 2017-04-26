From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: restore skb->sk before pskb_trim() call
Date: Wed, 26 Apr 2017 13:53:23 -0700
Message-ID: <20170426205322.fiixm7fvx3sg7luv@ast-mbp>
References: <1493222963.6453.77.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36540 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937706AbdDZUx1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 16:53:27 -0400
Received: by mail-pf0-f195.google.com with SMTP id v14so2578664pfd.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 13:53:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1493222963.6453.77.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 09:09:23AM -0700, Eric Dumazet wrote:
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
>     net: adjust skb->truesize in ___pskb_trim()
> 
> Fixes: 8f917bba0042 ("bpf: pass sk to helper functions")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: Andrey Konovalov <andreyknvl@google.com>

Ahh. Thanks for the fix.
Acked-by: Alexei Starovoitov <ast@kernel.org>
