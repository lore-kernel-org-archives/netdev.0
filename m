From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Wed, 11 Mar 2009 09:44:30 +0100
Message-ID: <20090311084430.GU425@pengutronix.de>
References: <1236738549-16703-1-git-send-email-yanok@emcraft.com> <20090310211841.388619ca@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilya Yanok <yanok@emcraft.com>,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46583 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbZCKIoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 04:44:44 -0400
Content-Disposition: inline
In-Reply-To: <20090310211841.388619ca@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Mar 10, 2009 at 09:18:41PM -0700, Stephen Hemminger wrote:
> On Wed, 11 Mar 2009 05:29:09 +0300
> Ilya Yanok <yanok@emcraft.com> wrote:
> 
> > +static char ethaddr[18];
> > +
> > +module_param_string(ethaddr, ethaddr, sizeof(ethaddr), 0);
> > +
> > +static void get_mac_addr(struct net_device *nd, unsigned char *pmac)
> > +{
> > +	int i;
> > +	char *p = ethaddr;
> > +
> > +	ethaddr[17] = 0;
> > +	for (i = 0; i < ETH_ALEN; i++, p++) {
> > +		pmac[i] = simple_strtoul(p, &p, 16);
> > +		if (*p != ':')
> > +			break;
> > +	}
> > +	if (i != ETH_ALEN - 1) {
> > +		pr_err("Wrong MAC address format!\n");
> > +		memset(pmac, 0, ETH_ALEN);
> > +	}
> > +}
> > +
> 
> Do you still need this? Only works with one board, configuration via
> module parameters is discouraged.  Same effect can be done by setting
> mac address with regular tools.

Except for root over nfs. Ok, the answer to this is usually 'use
initrd', but this is still a pita on embedded systems.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
