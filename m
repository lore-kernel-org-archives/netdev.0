From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v2 14/17] net: skb_array: expose peek API
Date: Tue, 6 Jun 2017 06:10:02 +0300
Message-ID: <20170606060909-mutt-send-email-mst@kernel.org>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
 <20170502154032.9304.50203.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50038 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751194AbdFFDKH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Jun 2017 23:10:07 -0400
Content-Disposition: inline
In-Reply-To: <20170502154032.9304.50203.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 02, 2017 at 08:40:32AM -0700, John Fastabend wrote:
> This adds a peek routine to skb_array.h for use with qdisc.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  include/linux/skb_array.h |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
> index f4dfade..33f1f0c 100644
> --- a/include/linux/skb_array.h
> +++ b/include/linux/skb_array.h
> @@ -72,6 +72,11 @@ static inline bool __skb_array_empty(struct skb_array *a)
>  	return !__ptr_ring_peek(&a->ring);
>  }
>  
> +static inline struct sk_buff *skb_array_peek(struct skb_array *a)
> +{
> +	return __ptr_ring_peek(&a->ring);
> +}
> +
>  static inline bool skb_array_empty(struct skb_array *a)
>  {
>  	return ptr_ring_empty(&a->ring);

I think it's better to call this __skb_array_peek: the issue
is that callers must be careful with it's use - see the comment
near __ptr_ring_peek.

-- 
MST
