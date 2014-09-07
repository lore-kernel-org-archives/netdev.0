From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v4 2/3] net-timestamp: Make the clone operation
 stand-alone from phy timestamping
Date: Sun, 7 Sep 2014 23:54:17 +0200
Message-ID: <20140907215417.GB3900@localhost.localdomain>
References: <20140904172906.7702.87598.stgit@ahduyck-bv4.jf.intel.com>
 <20140904173116.7702.30877.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, willemb@google.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:41746 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbaIGVyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 17:54:23 -0400
Received: by mail-we0-f177.google.com with SMTP id u57so1034608wes.36
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2014 14:54:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140904173116.7702.30877.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 04, 2014 at 01:31:35PM -0400, Alexander Duyck wrote:

> +struct sk_buff *skb_clone_sk(struct sk_buff *skb)
> +{
> +	struct sock *sk = skb->sk;
> +	struct sk_buff *clone;
> +
> +	if (!sk || !atomic_inc_not_zero(&sk->sk_refcnt))
> +		return NULL;
> +
> +	clone = skb_clone(skb, GFP_ATOMIC);
> +	if (!clone) {
> +		sock_put(sk);
> +		return NULL;
> +	}
> +
> +	clone->sk = sk;
> +	clone->destructor = sock_efree;
> +
> +	return clone;
> +}
> +EXPORT_SYMBOL(skb_clone_sk);

This function could use a little kerneldoc explaining its purpose and
when to use it.

Thanks,
Richard
