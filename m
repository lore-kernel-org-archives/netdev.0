From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] packet: tx_ring: allow the user to choose
 tx data offset
Date: Wed, 31 Oct 2012 13:14:34 -0400 (EDT)
Message-ID: <20121031.131434.910561089094397853.davem@davemloft.net>
References: <1350889014-2975-1-git-send-email-paul.chavent@onera.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Paul.Chavent@onera.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754341Ab2JaROk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 13:14:40 -0400
In-Reply-To: <1350889014-2975-1-git-send-email-paul.chavent@onera.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Chavent <Paul.Chavent@onera.fr>
Date: Mon, 22 Oct 2012 08:56:54 +0200

> +		if (unlikely((off < off_min) || (off_max < off))) {
> +			pr_err("payload offset (%d) out of range [%d;%d]\n",
> +				off, off_min, off_max);
> +			return -EINVAL;
> +		}

Users should not be able to spam the kernel log with error messages
by simply make setsockopt() calls.

This error log is inappropriate.
> @@ -110,6 +110,7 @@ struct packet_sock {
>  	unsigned int		tp_reserve;
>  	unsigned int		tp_loss:1;
>  	unsigned int		tp_tstamp;
> +	unsigned int		tp_tx_has_off:1;
>  	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
>  };

Please put the new bit field next to other existing bit fields so that
there is less wasted space in the struct.
