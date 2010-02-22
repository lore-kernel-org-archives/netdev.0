From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 22 Feb 2010 13:40:05 +0100
Message-ID: <20100222124004.GD2520@dhcp-lab-161.englab.brq.redhat.com>
References: <201002192152.o1JLqc8G031956@blc-10-1.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41604 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752240Ab0BVMl7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 07:41:59 -0500
Content-Disposition: inline
In-Reply-To: <201002192152.o1JLqc8G031956@blc-10-1.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2010 at 01:52:38PM -0800, Rasesh Mody wrote:
> From: Rasesh Mody <rmody@brocade.com>
> 
> This is patch 1/6 which contains linux driver source for
> Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.
> Source is based against net-next-2.6.
> 
> We wish this patch to be considered for inclusion in net-next-2.6
> 
> Signed-off-by: Rasesh Mody <rmody@brocade.com>
> ---
>  bnad.c | 3481 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  bnad.h |  341 ++++++
>  2 files changed, 3822 insertions(+)
[snip]
> void bnad_ioc_timeout(unsigned long ioc_arg)
> +{
> +	struct bnad *bnad = (struct bnad *)(((struct bfa_ioc*)ioc_arg)->bfa);
> +	spin_lock_irq(&bnad->priv_lock);
> +	spin_unlock_irq(&bnad->priv_lock);

Quite strange spin lock usage :)
  
> +u32
> +bnad_get_msglevel(struct net_device *netdev)
> +{
> +	return bnad_log_level;
> +}
> +
> +void
> +bnad_set_msglevel(struct net_device *netdev, u32 msglevel)
> +{
> +	struct bnad *bnad = netdev_priv(netdev);
> +	mutex_lock(&bnad->conf_mutex);
> +	bnad_log_level = msglevel;
> +	mutex_unlock(&bnad->conf_mutex);
> +}

bnad_log_level is not used anywhere.

