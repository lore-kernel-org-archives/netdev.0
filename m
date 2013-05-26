From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Patch v1] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Sun, 26 May 2013 20:28:21 +0400
Message-ID: <51A23825.7000303@cogentembedded.com>
References: <1369574241-21397-1-git-send-email-atomlin@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	pshelar@nicira.com, mst@redhat.com, alexander.h.duyck@intel.com,
	linux-kernel@vger.kernel.org
To: atomlin@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:53842 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754139Ab3EZQ20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 12:28:26 -0400
Received: by mail-lb0-f172.google.com with SMTP id p10so6092752lbi.31
        for <netdev@vger.kernel.org>; Sun, 26 May 2013 09:28:23 -0700 (PDT)
In-Reply-To: <1369574241-21397-1-git-send-email-atomlin@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 26-05-2013 17:17, atomlin@redhat.com wrote:

> From: Aaron Tomlin <atomlin@redhat.com>

> Failed GFP_ATOMIC allocations by the network stack result in dropped
> packets, which will be received on a subsequent retransmit, and an
> unnecessary, noisy warning with a kernel backtrace.

> These warnings are harmless, but they still cause users to panic and
> file bug reports over dropped packets. It would be better to hide the
> failed allocation warnings and backtraces, and let retransmits handle
> dropped packets quietly.

> Signed-off-by: Aaron Tomlin <atomlin@redhat.com>
> ---
>   net/core/skbuff.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index af9185d..02139d6 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -236,7 +236,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
>   		? skbuff_fclone_cache : skbuff_head_cache;
>
>   	if (sk_memalloc_socks() && (flags & SKB_ALLOC_RX))
> -		gfp_mask |= __GFP_MEMALLOC;
> +		gfp_mask |= (__GFP_MEMALLOC|__GFP_NOWARN);

    Parens not needed here.

WBR, Sergei
