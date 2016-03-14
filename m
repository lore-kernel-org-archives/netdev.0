From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v6 net-next 08/10] net: mvneta: bm: add support for
 hardware buffer management
Date: Mon, 14 Mar 2016 10:57:14 +0100
Message-ID: <20160314105714.1e97b4c1@redhat.com>
References: <1457944745-7634-1-git-send-email-gregory.clement@free-electrons.com>
	<1457944745-7634-9-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Timor Kardashov <timork@marvell.com>,
	Dmitri Epshtein <dima@marvell.com>,
	Sebastian Careba <nitroshift@yahoo.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33971 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933492AbcCNJ52 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 05:57:28 -0400
In-Reply-To: <1457944745-7634-9-git-send-email-gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 14 Mar 2016 09:39:03 +0100 Gregory CLEMENT <gregory.clement@free-electrons.com> wrote:

> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index b0ae69f84493..2847c0c291de 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
[...]
> -static void *mvneta_frag_alloc(const struct mvneta_port *pp)
> +void *mvneta_frag_alloc(unsigned int frag_size)
>  {
> -	if (likely(pp->frag_size <= PAGE_SIZE))
> -		return netdev_alloc_frag(pp->frag_size);
> +	if (likely(frag_size <= PAGE_SIZE))
> +		return netdev_alloc_frag(frag_size);

(I know you are modifying existing code here.)

Be aware that there is a significant performance advantage of using
napi_alloc_frag() over netdev_alloc_frag().  You obviously can only use
the NAPI call, if you indeed are running in NAPI/BH context.

>  	else
> -		return kmalloc(pp->frag_size, GFP_ATOMIC);
> +		return kmalloc(frag_size, GFP_ATOMIC);
>  }
> +EXPORT_SYMBOL_GPL(mvneta_frag_alloc);
  


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
