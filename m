From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 39 of 39] IB/ipath - use streaming copy in RDMA
 interrupt handler to reduce packet loss
Date: Thu, 29 Jun 2006 14:50:27 -0700 (PDT)
Message-ID: <20060629.145027.41636491.davem@davemloft.net>
References: <patchbomb.1151617251@eng-12.pathscale.com>
	<1b00209ef20a0e7893d8.1151617290@eng-12.pathscale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, rdreier@cisco.com, mst@mellanox.co.il,
	openib-general@openib.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932908AbWF2VwK@vger.kernel.org>
To: bos@pathscale.com
In-Reply-To: <1b00209ef20a0e7893d8.1151617290@eng-12.pathscale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bryan O'Sullivan <bos@pathscale.com>
Date: Thu, 29 Jun 2006 14:41:30 -0700

> +/*
> + * Copy data.  Try not to pollute the dcache with the source data,
> + * because we won't be reading it again.
> + */
> +#if defined(CONFIG_X86_64)
> +void *ipath_memcpy_nc(void *dest, const void *src, size_t n);
> +#else
> +#define ipath_memcpy_nc(dest, src, n) memcpy(dest, src, n)
> +#endif

A facility like this doesn't belong in some arbitrary driver layer.
It belongs as a generic facility the whole kernel could make use
of.

Please stop polluting the infiniband drivers with Opteron crap.
