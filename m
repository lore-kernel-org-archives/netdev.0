From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH 1/2] [net/wireless/iwlwifi] : iwlwifi 3945 Fix race
	conditional panic.
Date: Thu, 29 Nov 2007 09:10:56 +0800
Message-ID: <1196298656.7614.77.camel@debian.sh.intel.com>
References: <00e501c831ab$2e78daa0$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ipw3945-devel@lists.sourceforge.net,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:16063 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760811AbXK2BMq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 20:12:46 -0500
In-Reply-To: <00e501c831ab$2e78daa0$9c94fea9@jason>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2007-11-28 at 19:41 +0900, Joonwoo Park wrote:
> [net/wireless/iwlwifi] : iwlwifi 3945 Fix race conditional panic.
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> ---
> diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c
> b/drivers/net/wireless/iwlwifi/iwl3945-base.c
> index 465da4f..ac6c4a9 100644
> --- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
> +++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
> @@ -8570,6 +8570,7 @@ static void iwl_pci_remove(struct pci_dev *pdev)
>         IWL_DEBUG_INFO("*** UNLOAD DRIVER ***\n");
>  
>         mutex_lock(&priv->mutex);
> +       cancel_delayed_work_sync(&priv->init_alive_start);
>         set_bit(STATUS_EXIT_PENDING, &priv->status);
>         __iwl_down(priv);
>         mutex_unlock(&priv->mutex);

Good catch. But it will be better if you add it into
iwl_cancel_deferred_work().

Thanks,
-yi
