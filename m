From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: handle NAPI_GRO_FREE_STOLEN_HEAD case also in
 napi_frags_finish()
Date: Thu, 29 Jun 2017 15:55:28 -0400 (EDT)
Message-ID: <20170629.155528.1025956782358604257.davem@davemloft.net>
References: <20170629091336.3A0A6A1381@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170629091336.3A0A6A1381@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Thu, 29 Jun 2017 11:13:36 +0200 (CEST)

> Recently I started seeing warnings about pages with refcount -1. The
> problem was traced to packets being reused after their head was merged into
> a GRO packet by skb_gro_receive(). While bisecting the issue pointed to
> commit c21b48cc1bbf ("net: adjust skb->truesize in ___pskb_trim()") and
> I have never seen it on a kernel with it reverted, I believe the real
> problem appeared earlier when the option to merge head frag in GRO was
> implemented.
> 
> Handling NAPI_GRO_FREE_STOLEN_HEAD state was only added to GRO_MERGED_FREE
> branch of napi_skb_finish() so that if the driver uses napi_gro_frags()
> and head is merged (which in my case happens after the skb_condense()
> call added by the commit mentioned above), the skb is reused including the
> head that has been merged. As a result, we release the page reference
> twice and eventually end up with negative page refcount.
> 
> To fix the problem, handle NAPI_GRO_FREE_STOLEN_HEAD in napi_frags_finish()
> the same way it's done in napi_skb_finish().
> 
> Fixes: d7e8883cfcf4 ("net: make GRO aware of skb->head_frag")
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Applied and queued up for -stable, thanks.
