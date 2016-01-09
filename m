From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next v4 05/10] fm10k: add rtnl lock protection in
 fm10k_io_resume
Date: Sat, 9 Jan 2016 22:51:09 +0100
Message-ID: <20160109215109.GA16810@breakpoint.cc>
References: <1452352052-27574-1-git-send-email-hannes@stressinduktion.org>
 <1452352052-27574-6-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jesse@kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50852 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756294AbcAIVvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 16:51:13 -0500
Content-Disposition: inline
In-Reply-To: <1452352052-27574-6-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
> index 4eb7a6fa6b0ddc..846d9b731c8c14 100644
> --- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
> @@ -2350,8 +2350,10 @@ static void fm10k_io_resume(struct pci_dev *pdev)
>  	/* reset clock */
>  	fm10k_ts_reset(interface);
>  
> +	rtnl_lock();
>  	if (netif_running(netdev))
>  		err = fm10k_open(netdev);
> +	rtnl_lock();

Hmm.  Looks like copy&paste error :)
