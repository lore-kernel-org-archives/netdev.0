From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 38 of 39] IB/ipath - More changes to support InfiniPath
	on PowerPC 970 systems
Date: Fri, 07 Jul 2006 08:37:01 +1000
Message-ID: <1152225421.9862.12.camel@localhost.localdomain>
References: <c22b6c244d5db77f7b1d.1151617289@eng-12.pathscale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, rdreier@cisco.com, mst@mellanox.co.il,
	openib-general@openib.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57318 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1750831AbWGFWjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2006 18:39:36 -0400
To: "Bryan O'Sullivan" <bos@pathscale.com>
In-Reply-To: <c22b6c244d5db77f7b1d.1151617289@eng-12.pathscale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> +#if defined(__powerpc__)
> +	/* There isn't a generic way to specify writethrough mappings */
> +	pgprot_val(vma->vm_page_prot) |= _PAGE_NO_CACHE;
> +	pgprot_val(vma->vm_page_prot) |= _PAGE_WRITETHRU;
> +	pgprot_val(vma->vm_page_prot) &= ~_PAGE_GUARDED;
> +#endif

I don't see any case where having both NO_CACHE and WRITE_THRU can be
legal... It's one or the other.

> +/**
> + * ipath_unordered_wc - indicate whether write combining is ordered
> + *
> + * PowerPC systems (at least those in the 970 processor family)
> + * write partially filled store buffers in address order, but will write
> + * completely filled store buffers in "random" order, and therefore must
> + * have serialization for correctness with current InfiniPath chips.
> + *
> + */
> +int ipath_unordered_wc(void)
> +{
> +	return 1;
> +}

How is the above providing any kind of serialisation ?

Ben.


