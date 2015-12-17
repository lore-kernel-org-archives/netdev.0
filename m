From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] cxgb4: Use mask & shift while returning
 vlan_prio
Date: Wed, 16 Dec 2015 19:07:33 -0500 (EST)
Message-ID: <20151216.190733.272791166074460566.davem@davemloft.net>
References: <1450251988-9246-1-git-send-email-hariprasad@chelsio.com>
	<1450251988-9246-2-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbbLQAHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 19:07:35 -0500
In-Reply-To: <1450251988-9246-2-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 16 Dec 2015 13:16:25 +0530

> @@ -66,7 +66,7 @@ struct l2t_data {
>  
>  static inline unsigned int vlan_prio(const struct l2t_entry *e)
>  {
> -	return e->vlan >> 13;
> +	return (e->vlan & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;

e->vlan is a u16, the vlan priotity is the top 3 bits of the 16-bit
value, and finally the right shift will be non-signed.

Therefore this change is absolutely not necessary.

Please remove this patch from the series and resend.
