From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] packet: use percpu mmap tx frame pending
 refcount
Date: Tue, 14 Jan 2014 17:16:34 -0800 (PST)
Message-ID: <20140114.171634.1073334641652236373.davem@davemloft.net>
References: <1389543768-20234-1-git-send-email-dborkman@redhat.com>
	<1389543768-20234-4-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54162 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaAOBQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 20:16:35 -0500
In-Reply-To: <1389543768-20234-4-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sun, 12 Jan 2014 17:22:48 +0100

> +static int packet_read_pending(const struct packet_ring_buffer *rb)
> +{
> +	int i, refcnt = 0;
> +
> +	/* We don't use pending refcount in rx_ring. */
> +	if (rb->pending_refcnt == NULL)
> +		return 0;
> +
> +	for_each_possible_cpu(i)
> +		refcnt += *per_cpu_ptr(rb->pending_refcnt, i);
> +
> +	return refcnt;
> +}

David Laight stated that this works properly only if all the arithmetic
is unsigned.

Therefore, maybe use "unsigned int" for refcnt here?

Can you respin this series with that fixed?

Thanks.
