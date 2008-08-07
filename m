From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] METH: fix MAC address setup
Date: Thu, 07 Aug 2008 02:12:21 -0400
Message-ID: <489A9245.4070105@pobox.com>
References: <20080730231424.CD5E8DEBB8@solo.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	ralf@linux-mips.org
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47944 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755120AbYHGGM0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:12:26 -0400
In-Reply-To: <20080730231424.CD5E8DEBB8@solo.franken.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Bogendoerfer wrote:
> Setup of the mac filter lost the upper 16bit of the mac address. This
> bug got unconvered by a patch, which fixed the promiscous handling.
> 
> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
> ---
> 
>  drivers/net/meth.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/meth.c b/drivers/net/meth.c
> index 4cb364e..0a97c26 100644
> --- a/drivers/net/meth.c
> +++ b/drivers/net/meth.c
> @@ -100,7 +100,7 @@ static inline void load_eaddr(struct net_device *dev)
>  	DPRINTK("Loading MAC Address: %s\n", print_mac(mac, dev->dev_addr));
>  	macaddr = 0;
>  	for (i = 0; i < 6; i++)
> -		macaddr |= dev->dev_addr[i] << ((5 - i) * 8);
> +		macaddr |= (u64)dev->dev_addr[i] << ((5 - i) * 8);

applied


