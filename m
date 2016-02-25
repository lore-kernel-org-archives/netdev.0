From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3] ibmvnic: map L2/L3/L4 header descriptors
 to firmware
Date: Thu, 25 Feb 2016 00:12:34 -0500 (EST)
Message-ID: <20160225.001234.830392805325286378.davem@davemloft.net>
References: <1456371283-24349-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbcBYFMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 00:12:36 -0500
In-Reply-To: <1456371283-24349-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Wed, 24 Feb 2016 21:34:43 -0600

> +
> +static union sub_crq *build_hdr_descs_arr(struct sk_buff *skb,
> +					  int *num_entries,
> +					  union sub_crq subcrq, u8 hdr_field)
> +{
> +	unsigned char *hdr_data;
> +	union sub_crq *entries;
> +	int hdr_len[3] = {0};
> +	int tot_len;
> +
> +	hdr_data = build_hdr_data(hdr_field, skb, hdr_len, &tot_len);
> +	if (!hdr_data)
> +		return NULL;
> +
> +	*num_entries += calc_num_hdr_descs(tot_len);
> +
> +	entries = alloc_scrq_array(*num_entries, subcrq);

Doing an extra memory allocation for every transmit packet is going
to kill performance.  We are spending enormous amounts of effort
trying to eliminate the bare minimum memory allocations that occur
as-is because that cost is what dominates and this patch is going
to make it even worse for this device.

I don't care what offloads this enables, the implementation is
unacceptable from a performance standpoint.

Also, you should only add this new code when the offloads that make
use of the feature are added as well, otherwise it is unused bloat.

I am not applying this patch, there are so many things wrong with it.

Sorry.
