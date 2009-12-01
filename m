From: David Miller <davem@davemloft.net>
Subject: Re: Subject: [PATCH 3/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 30 Nov 2009 16:21:51 -0800 (PST)
Message-ID: <20091130.162151.107218779.davem@davemloft.net>
References: <200911260928.nAQ9SW9r003958@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ddutt@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43933
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752123AbZLAAVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 19:21:45 -0500
In-Reply-To: <200911260928.nAQ9SW9r003958@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Debashis Dutt <ddutt@brocade.com>
Date: Thu, 26 Nov 2009 01:28:32 -0800

> +#define BNA_PAGE_SIZE	PAGE_SIZE
> +#define BNA_PAGE_SHIFT	PAGE_SHIFT
> +
> +#define BNA_ASSERT(x) BUG_ON(!(x))
> +
> +#define bna_dma_addr64(_x) cpu_to_be64((_x))
> +
> +#define bfa_addr_t 	char __iomem *
> +#define bfa_u32(__pa64)	((__pa64) >> 32)
> +
> +#define bfa_reg_read(_raddr)		readl(_raddr)
> +#define bfa_reg_write(_raddr, _val)	writel(_val, _raddr)
> +#define bfa_os_panic()

All of the definitions in this header file are inappropriate.

Use the standard types and interfaces the Linux kernel provides in the
actual source code.

I know what you're trying to do, but it's not appropriate.

You want a layer of abstract types and macros so you can compile the
same code in different environments and just swap out this one header
file and we've been trying to tell you over and over again that you
can't do that.

Also, the "version.h" file that contains just one macro definition is
excessive.  This driver already has move than 30 (!!!!!) header files,
that's absolutely and completely rediculious.

Do you know that there are many modern network device drivers in the
kernel tree that exist in one single C and one single header file?

That's the model you should drift your driver towards, rather than
one that has on the order of 30+ source files.

This driver still needs a ton of work, sorry...
