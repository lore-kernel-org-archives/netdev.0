From: marcelo.leitner@gmail.com
Subject: Re: [PATCH net-next 1/2] skbuff: Add pskb_extract() helper function
Date: Fri, 22 Apr 2016 20:27:50 -0300
Message-ID: <20160422232750.GB1594@localhost.localdomain>
References: <cover.1461086306.git.sowmini.varadhan@oracle.com>
 <8d683318ede700f5f1b4d4333dfad8a1935f9ce6.1461086306.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	santosh.shilimkar@oracle.com, davem@davemloft.net,
	eric.dumazet@gmail.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751800AbcDVX1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 19:27:54 -0400
Content-Disposition: inline
In-Reply-To: <8d683318ede700f5f1b4d4333dfad8a1935f9ce6.1461086306.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 20, 2016 at 03:17:41AM -0700, Sowmini Varadhan wrote:
...
> +/* Extract to_copy bytes starting at off from skb, and return this in
> + * a new skb
> + */
> +struct sk_buff *pskb_extract(struct sk_buff *skb, int off,
> +			     int to_copy, gfp_t gfp)
> +{
> +	struct sk_buff  *clone = skb_clone(skb, gfp);
> +
> +	if (!clone)
> +		return NULL;
> +
> +	if (pskb_carve(clone, off, gfp) < 0) {
> +		pr_warn("pskb_carve failed\n");

You most likely don't want these pr_warn

> +		kfree_skb(clone);
> +		return NULL;
> +	}
> +
> +	if (pskb_trim(clone, to_copy)) {
> +		pr_warn("pskb_trim failed\n");
> +		kfree_skb(clone);
> +		return NULL;
> +	}
> +	return clone;

Then these two blocks can be just:

	if (pskb_carve(clone, off, gfp) < 0 ||
	    pskb_trim(clone, to_copy)) {
		kfree_skb(clone);
		clone = NULL;
	}
	return clone;

  Marcelo

> +}
> +EXPORT_SYMBOL(pskb_extract);
> -- 
> 1.7.1
> 
