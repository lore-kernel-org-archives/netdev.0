From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 07/15] i40iw: add hw and utils files
Date: Thu, 17 Dec 2015 08:07:36 -0800
Message-ID: <20151217160736.GA19013@infradead.org>
References: <1450295919-17292-1-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-2-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-3-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-4-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-5-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-6-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-7-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-8-git-send-email-faisal.latif@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1450295919-17292-8-git-send-email-faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +#ifndef UNREFERENCED_PARAMETER
> +#define UNREFERENCED_PARAMETER(_p)	\
> +{					\
> +	(_p) = (_p);			\
> +}
> +#endif

No need for this, just remove it.

> +#define I40E_MASK(mask, shift) (mask << shift)

Please just opencode the shit, this macro is silly.

> +#define i40iw_flush(a)          readl((a)->hw_addr + I40E_GLGEN_STAT)
> +
> +#define wr32(a, reg, value)     writel((value), (a)->hw_addr + (reg))
> +#define rd32(a, reg)            readl((a)->hw_addr + (reg))

Please urn these into inlines.

> +
> +#ifndef readq
> +static inline u64 rd64(u8 * __iomem addr)
> +{
> +	return ((u64)readl(addr)) | (((u64)readl(addr + 4UL)) << 32);
> +}
> +#else
> +#define rd64(a)            readq((a))
> +#endif

Please use the magic in <linux/io-64-nonatomic-lo-hi.h> instead.

> +
> +#define db_wr32(a, value)       writel((value), (a))

Pleas remove this pointless wrapper.

> +void SLEEP(u8 ms);

Please give this function a sensible name.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
