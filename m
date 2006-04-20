From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH 9/10] [IOAT] Add sysctl to tuning IOAT offloaded IO threshold
Date: Thu, 20 Apr 2006 16:16:43 -0500
Message-ID: <20060420211643.GJ26746@pb15.lixom.net>
References: <Pine.LNX.4.44.0604201341530.22544-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:61910 "EHLO mail.lixom.net")
	by vger.kernel.org with ESMTP id S1751339AbWDTVlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 17:41:20 -0400
To: Andrew Grover <andrew.grover@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0604201341530.22544-100000@isotope.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Apr 20, 2006 at 01:50:40PM -0700, Andrew Grover wrote:
> 
> Any socket recv of less than this ammount will not be offloaded
[...]
> --- a/net/core/user_dma.c
> +++ b/net/core/user_dma.c
> @@ -33,6 +33,10 @@
>  
>  #ifdef CONFIG_NET_DMA
>  
> +#define NET_DMA_DEFAULT_COPYBREAK 1024
> +
> +int sysctl_tcp_dma_copybreak = NET_DMA_DEFAULT_COPYBREAK;
> +

The breakpoint is highly likely to be at different points on various
architectures and platforms depending on what they look like, where in
the system the DMA engine is, how efficient regular memcpy is, etc.

I would like to see it as a config option instead, so it will at least
be possible to tune per-arch (via default config, etc).


-Olof

