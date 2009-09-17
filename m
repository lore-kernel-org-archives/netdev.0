From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ks8851_ml ethernet network driver
Date: Wed, 16 Sep 2009 21:03:15 -0700
Message-ID: <20090916210315.04dc743e@s6510>
References: <20090917023836.GA15260@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, Choi@kroah.com,
	David <David.Choi@Micrel.Com>, Jeff Garzik <jgarzik@redhat.com>
To: "Li, Charles" <Charles.Li@Micrel.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51961 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750730AbZIQEDS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2009 00:03:18 -0400
In-Reply-To: <20090917023836.GA15260@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Sep 2009 19:38:36 -0700
Greg KH <greg@kroah.com> wrote:

> /**
> + * ks_irq - device interrupt handler
> + * @irq: Interrupt number passed from the IRQ hnalder.
> + * @pw: The private word passed to register_irq(), our struct ks_net.
> + *
> + * This is the handler invoked to find out what happened
> + *
> + * Read the interrupt status, work out what needs to be done and then clear
> + * any of the interrupts that are not needed.
> + */
> +
> +static irqreturn_t ks_irq(int irq, void *pw)
> +{
> +	struct ks_net *ks = pw;
> +	struct net_device *netdev = ks->netdev;
> +	u16 status;
> +
> +	/*this should be the first in IRQ handler */
> +	ks_save_cmd_reg(ks);
> +
> +	status = ks_rdreg16(ks, KS_ISR);
> +	ks_wrreg16(ks, KS_ISR, status);

if status == 0 or status == ~0 then device should not return IRQ_HANDLED.
In the former case, the IRQ is shared, in later case the device is not present
on the bus (hotplug).
