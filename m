From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] XFRM: MIGRATE enhancements
Date: Thu, 11 Sep 2008 03:47:41 -0700 (PDT)
Message-ID: <20080911.034741.263645111.davem@davemloft.net>
References: <8763puwrm8.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shinta@sfc.wide.ad.jp,
	nakam@linux-ipv6.org, yoshfuji@linux-ipv6.org
To: arno@natisbad.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47465
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752406AbYIKKrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 06:47:47 -0400
In-Reply-To: <8763puwrm8.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: arno@natisbad.org (Arnaud Ebalard)
Date: Thu, 21 Aug 2008 13:10:39 +0200

> XFRM: MIGRATE enhancements (draft-ebalard-mext-pfkey-enhanced-migrate)
> 
> Provides implementation of the enhancements of XFRM/PF_KEY MIGRATE mechanism
> specified in draft-ebalard-mext-pfkey-enhanced-migrate-00. Defines associated
> PF_KEY SADB_X_EXT_KMADDRESS extension XFMR/netlink XFRMA_KMADDRESS attribute.
> 
> Signed-off-by: Arnaud Ebalard <arno@natisbad.org>

I'm mostly ok with this, but:

> @@ -1745,18 +1753,19 @@ static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
>  {
>  	struct xfrm_userpolicy_id *pi = nlmsg_data(nlh);
>  	struct xfrm_migrate m[XFRM_MAX_DEPTH];
> +	struct xfrm_kmaddress km;
>  	u8 type;
>  	int err;
>  	int n = 0;
>  
> -	if (attrs[XFRMA_MIGRATE] == NULL)
> +	if (attrs[XFRMA_MIGRATE] == NULL || attrs[XFRMA_KMADDRESS] == NULL)
>  		return -EINVAL;

This part I don't like.

This is a new restriction and will break old binaries.

Can't we cook up some kind of default kmaddress object it none is
specified by the user?  Alternatively, if we are in an environment
where the tools don't understand this facility, they won't care
what the kmaddress even is.

Generally speaking, when extending existing facilities with new
attributes, you cannot make their existence suddenly a requirement.
That breaks stuff.
