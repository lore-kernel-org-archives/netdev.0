From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: cls_u32: Add support for skip-sw
 flag to tc u32 classifier.
Date: Wed, 11 May 2016 19:23:16 -0400 (EDT)
Message-ID: <20160511.192316.1290350535833930948.davem@davemloft.net>
References: <1462821524-2534-1-git-send-email-sridhar.samudrala@intel.com>
	<1462821524-2534-2-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbcEKXXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 19:23:38 -0400
In-Reply-To: <1462821524-2534-2-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Date: Mon,  9 May 2016 12:18:44 -0700

> On devices that support TC U32 offloads, this flag enables a filter to be
> added only to HW. skip-sw and skip-hw are mutually exclusive flags. By
> default without any flags, the filter is added to both HW and SW, but no
> error checks are done in case of failure to add to HW. With skip-sw,
> failure to add to HW is treated as an error.

I really want you to provide a "[PATCH net-next 0/2]" header posting
explaining what this series is doing, and why.

This is a core semantic issue, and we have to make sure all amongst us
that we are all comfortable with exporting the offloadability controls
in the way you are implementing them.

Also:

> @@ -871,10 +889,15 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
>  			return err;
>  		}
>  
> +		err = u32_replace_hw_knode(tp, new, flags);
> +		if (err) {
> +			u32_destroy_key(tp, new, false);
> +			return err;
> +		}
> +
>  		u32_replace_knode(tp, tp_c, new);
>  		tcf_unbind_filter(tp, &n->res);
>  		call_rcu(&n->rcu, u32_delete_key_rcu);
> -		u32_replace_hw_knode(tp, new, flags);
>  		return 0;
>  	}
>  

Are you sure this reordering is OK?
