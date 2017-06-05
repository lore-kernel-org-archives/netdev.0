From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v10 0/5] Avoiding stack overflow in
 skb_to_sgvec
Date: Sun, 04 Jun 2017 23:03:27 -0400 (EDT)
Message-ID: <20170604.230327.148898250524251943.davem@davemloft.net>
References: <20170604021626.11968-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-hardening@lists.openwall.com
To: Jason@zx2c4.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170604021626.11968-1-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Sun,  4 Jun 2017 04:16:21 +0200

> Changes v9->v10:
>    - Spaces to tabs on one line.
>    - Added some acked-by, reviewed-by lines.

I wish in the future you would retain the entire change history, and
keep it in it's entirety here in the header postings.  That list of
adjustments is important and might be useful to someone in the future
("why didn't they do this, oh they decided to not do that
intentionally I can see that in the Change list").

> The recent bug with macsec and historical one with virtio have
> indicated that letting skb_to_sgvec trounce all over an sglist
> without checking the length is probably a bad idea. And it's not
> necessary either: an sglist already explicitly marks its last
> item, and the initialization functions are diligent in doing so.
> Thus there's a clear way of avoiding future overflows.
> 
> So, this patchset, from a high level, makes skb_to_sgvec return
> a potential error code, and then adjusts all callers to check
> for the error code. There are two situations in which skb_to_sgvec
> might return such an error:
> 
>    1) When the passed in sglist is too small; and
>    2) When the passed in skbuff is too deeply nested.
> 
> So, the first patch in this series handles the issues with
> skb_to_sgvec directly, and the remaining ones then handle the call
> sites.

Applied to net-next.
