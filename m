From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v13] openvswitch: enable NSH support
Date: Mon, 30 Oct 2017 10:01:34 +0900 (KST)
Message-ID: <20171030.100134.1999494058214685235.davem@davemloft.net>
References: <1509003916-31897-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jbenc@redhat.com,
        e@erig.me, pshelar@ovn.org
To: yi.y.yang@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57088 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751429AbdJ3BBj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 21:01:39 -0400
In-Reply-To: <1509003916-31897-1-git-send-email-yi.y.yang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Yang <yi.y.yang@intel.com>
Date: Thu, 26 Oct 2017 15:45:16 +0800

> OVS master and 2.8 branch has merged NSH userspace
> patch series, this patch is to enable NSH support
> in kernel data path in order that OVS can support
> NSH in compat mode by porting this.
> 
> Signed-off-by: Yi Yang <yi.y.yang@intel.com>

One small request for function naming:

> diff --git a/include/net/nsh.h b/include/net/nsh.h
> index a1eaea2..7dcf377 100644
> --- a/include/net/nsh.h
> +++ b/include/net/nsh.h
> @@ -304,4 +304,7 @@ static inline void nsh_set_flags_ttl_len(struct nshhdr *nsh, u8 flags,
>  			NSH_FLAGS_MASK | NSH_TTL_MASK | NSH_LEN_MASK);
>  }
>  
> +int skb_push_nsh(struct sk_buff *skb, const struct nshhdr *pushed_nh);
> +int skb_pop_nsh(struct sk_buff *skb);
> +
>  #endif /* __NET_NSH_H */

All functions named "skb_*" should be core SKB handling functions found
and implemented in include/linux/skbuff.h and net/core/skbuff.c

Protocol specific helpers like this should be named "$PROTOCOL_NAME_*"
so please renamed these something like "nsh_header_push()" and
"nsh_header_pop()".

Thank you.
