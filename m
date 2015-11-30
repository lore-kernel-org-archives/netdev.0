From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next v4 2/2] net: add driver for Netronome
 NFP4000/NFP6000 NIC VFs
Date: Mon, 30 Nov 2015 10:42:26 -0500 (EST)
Message-ID: <20151130.104226.1974076120162436486.davem@redhat.com>
References: <1445969758-12779-1-git-send-email-jakub.kicinski@netronome.com>
	<1448465944-32294-1-git-send-email-jakub.kicinski@netronome.com>
	<1448465944-32294-3-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
	rolf.neugebauer@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56828 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752297AbbK3Pm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2015 10:42:27 -0500
In-Reply-To: <1448465944-32294-3-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed, 25 Nov 2015 15:39:04 +0000

> +config NFP_NET_DEBUG
> +	bool "Debug support for Netronome(R) NFP3200/NFP6000 NIC drivers"
> +	depends on NFP_NET || NFP_NETVF
> +	---help---
> +	  Enable extra sanity checks and debugfs support in
> +	  Netronome(R) NFP3200/NFP6000 NIC PF and VF drivers.
> +	  Note: selecting this option may adversely impact
> +		performance.
 ...
> +#ifdef CONFIG_NFP_NET_DEBUG
> +#define nn_assert(cond, fmt, args...)					\
> +	do {								\
> +		if (unlikely(!(cond))) {				\
> +			pr_err("assertion %s failed\n", #cond);		\
> +			pr_err(fmt, ## args);				\
> +			BUG();						\
> +		}							\
> +	} while (0)
> +#else
> +#define nn_assert(cond, fmt, args...)	do { } while (0)
> +#endif

This is really not appropriate.

Use WARN_ON() et al. as appropriate to assert things, and in particular
_AVOID_ BUG() in pretty much all cases and attempt to continue running
somehow with error handling paths etc.

Use of BUG() is discouraged in all except the most extreme cases where
the kernel cannot continue to execute at all.

Thanks.
