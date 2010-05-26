From: Stanislaw Gruszka <stf_xl@wp.pl>
Subject: Re: [Linux-ATM-General] RX/close vcc race with solos/atmtcp/usbatm/he
Date: Wed, 26 May 2010 20:51:09 +0200
Message-ID: <20100526185109.GA2555@r2bh72.net.upc.cz>
References: <1274872584.20576.13579.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.8]:29936 "EHLO mx4.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753578Ab0EZRuL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 May 2010 13:50:11 -0400
Content-Disposition: inline
In-Reply-To: <1274872584.20576.13579.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 26, 2010 at 12:16:24PM +0100, David Woodhouse wrote:
> The problem is that the 'find_vcc' functions in these drivers are
> returning a vcc with the ATM_VF_READY bit cleared, because it's already
> in the process of being destroyed. If we fix that simple oversight,
> there's still a race condition because the socket can still be closed
> (and completely freed, afaict) between our call to find_vcc() and our
> call to vcc->push() in the RX tasklet.
> 
> Here's a patch for solos-pci which should fix it. We prevent the race by
> making the dev->ops->close() function wait for the RX tasklet to
> complete, so it can't still be using the vcc in question.

I do not think this is problem with usbatm. We use custom vcc_list with
custom usbatm_vcc_data entries. We remove entry on atmdev_ops->close()
within tasklet_disable()/tasklet_enable() section. After that
rx tasklet will not find usbatm_vcc_data for corresponding vpi, vpi.

Stanislaw
