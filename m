From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: add-a-slab-for-ethernet.patch
Date: Tue, 13 Apr 2004 13:01:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040413200117.GB36793@gaz.sfgoth.com>
References: <20040412222532.25c7e1b9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040412222532.25c7e1b9.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> +#if (PAGE_SIZE != 4096)	/* special cache for eth skbs - 5 fit into one 8 kB page */
> +	CACHE(1620)
> +#endif

Nitpicks:

  1. Shouldn't this be (PAGE_SIZE > 4096)?  Yeah, it's not very likely that
     we'll ever have to support an arch w/ a page size <4K (I believe the
     linux-vax port uses 4K superpages, not the 1K native page size) but it
     doesn't hurt to be careful.

  2. Maybe also add "&& defined(CONFIG_NET)" to that?  You could also argue
     for CONFIG_ETHERNET but there's lots of cases where people might want
     to use ethernet-sized frames (bridged over ATM, whatever) even if they
     don't have any ethernet cards installed.

     Doubt there's too many people with 8K page sizes and no networking
     support compiled in... but today's high-end is tomorrow's embedded
     processor :-)

-Mitch
