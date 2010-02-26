From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 4/7] cxgb4: Add packet queues and packet DMA code
Date: Fri, 26 Feb 2010 15:57:56 -0800
Message-ID: <20100226155756.09c0485c@nehalam>
References: <1267227339-8076-1-git-send-email-dm@chelsio.com>
	<1267227339-8076-2-git-send-email-dm@chelsio.com>
	<1267227339-8076-3-git-send-email-dm@chelsio.com>
	<1267227339-8076-4-git-send-email-dm@chelsio.com>
	<1267227339-8076-5-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46761 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966562Ab0BZX6N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 18:58:13 -0500
In-Reply-To: <1267227339-8076-5-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Feb 2010 15:35:36 -0800
Dimitris Michailidis <dm@chelsio.com> wrote:

> +
> +/**
> + *	need_skb_unmap - does the platform need unmapping of sk_buffs?
> + *
> + *	Returns true if the platfrom needs sk_buff unmapping.  The compiler
> + *	optimizes away unecessary code if this returns true.
> + */
> +static inline int need_skb_unmap(void)
> +{
> +	/*
> +	 * This structure is used to tell if the platfrom needs buffer
> +	 * unmapping by checking if DECLARE_PCI_UNMAP_ADDR defines anything.
> +	 */
> +	struct dummy {
> +		DECLARE_PCI_UNMAP_ADDR(addr);
> +	};
> +
> +	return sizeof(struct dummy) != 0;
> +}
> +

I would prefer one code path and let the compiler decide if unmap
should be nop; rather than this kind of trick code.

-- 
