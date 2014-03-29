From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: Add a test to see if a skb is freeable in irq
 context
Date: Sat, 29 Mar 2014 18:09:45 -0400 (EDT)
Message-ID: <20140329.180945.1823589321953879448.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6E02DB@AcuExch.aculab.com>
	<87mwgbkttv.fsf_-_@x220.int.ebiederm.org>
	<87eh1nktrw.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, eric.dumazet@gmail.com, ben@decadent.org.uk,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	David.Laight@ACULAB.COM
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878AbaC2WJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 18:09:47 -0400
In-Reply-To: <87eh1nktrw.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 27 Mar 2014 18:15:47 -0700

> Currently netpoll and skb_release_head_state assume that a skb is
> freeable in hard irq context except when skb->destructor is set.
> 
> The reality is far from this.  So add a function skb_irq_freeable to
> compute the full test and in the process be the living documentation of
> what the requirements are of actually freeing a skb in hard irq context.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
 ...
> +	return !skb->destructor &&
> +#if IS_ENABLED(CONFIG_XFRM)
> +		!skb->sp &&
> +#endif
> +#if IS_ENABLED(CONFIG_NF_CONNTRACK)
> +		!skb->nfct &&
> +#endif
> +		!skb->_skb_refdst &&
> +		!skb_has_frag_list(skb);

I think you need to add "!skb->nf_bridge &&" to this test.
