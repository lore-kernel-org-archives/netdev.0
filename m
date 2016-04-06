From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next] net: ipv4: Consider failed nexthops in
 multipath routes
Date: Wed, 06 Apr 2016 11:35:20 -0400 (EDT)
Message-ID: <20160406.113520.277173843253798547.davem@davemloft.net>
References: <1459728547-36371-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ja@ssi.bg
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42429 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbcDFPfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:35:41 -0400
In-Reply-To: <1459728547-36371-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sun,  3 Apr 2016 17:09:07 -0700

> +		rcu_read_lock_bh();
> +
> +		n = __neigh_lookup_noref(&arp_tbl, &nh->nh_gw, nh->nh_dev);
> +		if (n)
> +			state = n->nud_state;
> +
> +		rcu_read_unlock_bh();

Please use __ipv4_neigh_lookup_noref() (from net/arp.h), it inlines
the comparison and hash functions and is therefore several orders of
magnitude faster.
