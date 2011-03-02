From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 24/27] HFI: hf network driver
Date: Wed, 2 Mar 2011 14:26:17 -0800
Message-ID: <20110302142617.112bd9cb@nehalam>
References: <1299100213-8770-1-git-send-email-dykmanj@linux.vnet.ibm.com>
	<1299100213-8770-24-git-send-email-dykmanj@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	" William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	" Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	" Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	" Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: dykmanj@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48179 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757886Ab1CBW0U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 17:26:20 -0500
In-Reply-To: <1299100213-8770-24-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  2 Mar 2011 16:10:10 -0500
dykmanj@linux.vnet.ibm.com wrote:

> +struct hf_if {
> +	u32			idx;			/* 0, 1, 2, 3 ...   */
> +	u32			ai;			/* 0=hfi0, 1=hfi1   */
> +	char			name[HF_MAX_NAME_LEN];
> +	u32			isr_id;
> +	u32			ip_addr;
> +	u32			state;			/* CLOSE, OPEN */
> +	spinlock_t		lock;			/* lock for state */
> +	u32			sfifo_fv_polarity;
> +	u32			sfifo_slots_per_blk;
> +	u32			sfifo_packets;
> +	void __iomem		*doorbell;		/* mapped mmio_regs */
> +	struct hf_fifo		tx_fifo;
> +	struct hf_fifo		rx_fifo;
> +	struct hfi_client_info	client;
> +	struct sk_buff		**tx_skb;		/* array to store tx
> +							   2k skb */
> +	void			*sfifo_finishvec;
> +	struct net_device_stats	net_stats;
> +};

You don't need net_stats in this structure if you use
the standard netdev->stats structure instead.

You won't need hf_get_stats then..

-- 
