From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH try#5] Blackfin ethernet driver: on chip ethernet MAC
 controller driver
Date: Tue, 17 Jul 2007 02:11:53 +0900 (JST)
Message-ID: <20070717.021153.74661454.yoshfuji@linux-ipv6.org>
References: <1184604542.6107.44.camel@roc-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael.hennerich@analog.com, mb@bu3sch.de, vapier.adi@gmail.com,
	jeff@garzik.org, hch@infradead.org, dcbw@redhat.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, joe@perches.com, yoshfuji@linux-ipv6.org
To: bryan.wu@analog.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:48096 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516AbXGPRLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 13:11:12 -0400
In-Reply-To: <1184604542.6107.44.camel@roc-laptop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <1184604542.6107.44.camel@roc-laptop> (at Tue, 17 Jul 2007 00:49:02 +0800), Bryan Wu <bryan.wu@analog.com> says:

> +static void bf537mac_set_multicast_list(struct net_device *dev)
> +{
> +	u32 sysctl;
> +
> +	if (dev->flags & IFF_PROMISC) {
> +		printk(KERN_INFO "%s: set to promisc mode\n", dev->name);
> +		sysctl = bfin_read_EMAC_OPMODE();
> +		sysctl |= RAF;
> +		bfin_write_EMAC_OPMODE(sysctl);
> +	} else if (dev->flags & IFF_ALLMULTI || dev->mc_count > 16) {
> +		/* accept all multicast */
> +		sysctl = bfin_read_EMAC_OPMODE();
> +		sysctl |= PAM;
> +		bfin_write_EMAC_OPMODE(sysctl);
> +	} else if (dev->mc_count) {
> +		/* set multicast */
> +	} else {
> +		/* clear promisc or multicast mode */
> +		sysctl = bfin_read_EMAC_OPMODE();
> +		sysctl &= ~(RAF | PAM);
> +		bfin_write_EMAC_OPMODE(sysctl);
> +	}
> +}
> +

Is this function really correct?

Please make sure to set up multicast list on device, or
set "all multi" on device if you do not know what to do; e.g.

static void bf537mac_set_multicast_list(struct net_device *dev)
{
     u32 sysctl;

     if (dev->flags & IFF_PROMISC) {
             printk(KERN_INFO "%s: set to promisc mode\n", dev->name);
             sysctl = bfin_read_EMAC_OPMODE();
             sysctl |= RAF;
             bfin_write_EMAC_OPMODE(sysctl);
     } else if (dev->flags & IFF_ALLMULTI || dev->mc_count) {
             /* accept all multicast */
             sysctl = bfin_read_EMAC_OPMODE();
             sysctl |= PAM;
             bfin_write_EMAC_OPMODE(sysctl);
     } else {
             /* clear promisc or multicast mode */
             sysctl = bfin_read_EMAC_OPMODE();
             sysctl &= ~(RAF | PAM);
             bfin_write_EMAC_OPMODE(sysctl);
     }
}
--yoshfuji
