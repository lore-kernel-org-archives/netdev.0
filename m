From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC v2 net-next 05/10] qede: Add basic network device support
Date: Thu, 24 Sep 2015 14:25:36 -0700
Message-ID: <20150924142536.052d6175@urahara>
References: <1442499839-22762-1-git-send-email-Yuval.Mintz@qlogic.com>
	<1442499839-22762-6-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36447 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbbIXVZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 17:25:26 -0400
Received: by pacgz1 with SMTP id gz1so1270490pac.3
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 14:25:26 -0700 (PDT)
In-Reply-To: <1442499839-22762-6-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Sep 2015 17:23:54 +0300
Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:

> +#define QEDE_NAPI_WEIGHT	(NAPI_POLL_WEIGHT)
> +

Why not just use existing constant rather than walpapering?
> +
> +#define U64_LO(x)			((u32)(((u64)(x)) & 0xffffffff))
> +#define U64_HI(x)			((u32)(((u64)(x)) >> 32))
> +#define HILO_U64(hi, lo)		((((u64)(hi)) << 32) + (lo))

Why reinvent upper32 and lower32?

> +struct qede_rx_queue {
> +	__le16			*hw_cons_ptr;

The __ variants of constants should be reserved for use in user visible
API's

> +	struct sw_rx_data	*sw_rx_ring;
> +	u16			sw_rx_cons;
> +	u16			sw_rx_prod;
> +	struct qed_chain	rx_bd_ring;
> +	struct qed_chain	rx_comp_ring;
> +	void __iomem		*hw_rxq_prod_addr;
> +
> +	int			rx_buf_size;

Shouldn't rx_buf_size be unsigned?
