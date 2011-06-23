From: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Subject: Re: [PATCH 1/2] iwlwifi: use pci_dev->revision, again
Date: Thu, 23 Jun 2011 08:02:45 -0700
Message-ID: <1308841365.13397.274.camel@wwguy-huron>
References: <201106231841.40691.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20085 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759670Ab1FWPeX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2011 11:34:23 -0400
In-Reply-To: <201106231841.40691.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-23 at 07:41 -0700, Sergei Shtylyov wrote:
> Commit ff938e43d39e926de74b32a3656c190f979ab642 (net: use pci_dev->revision,
> again) already converted this driver to using the 'revision' field of 'struct
> pci_dev' but commit c2974a1d18832a9fffb2eb389c3878f5c4ed92f1 (iwlagn: remove
> rev_id) later reverted that change for no reason. Now restore the change...
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> 
> ---
> The patch is against the recent Linus' tree.
> 
>  drivers/net/wireless/iwlwifi/iwl-agn.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6/drivers/net/wireless/iwlwifi/iwl-agn.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/wireless/iwlwifi/iwl-agn.c
> +++ linux-2.6/drivers/net/wireless/iwlwifi/iwl-agn.c
> @@ -3275,10 +3275,9 @@ struct ieee80211_ops iwlagn_hw_ops = {
>  
>  static u32 iwl_hw_detect(struct iwl_priv *priv)
>  {
> -	u8 rev_id;
> +	IWL_DEBUG_INFO(priv, "HW Revision ID = 0x%X\n",
> +		       priv->pci_dev->revision);
>  
> -	pci_read_config_byte(priv->pci_dev, PCI_REVISION_ID, &rev_id);
> -	IWL_DEBUG_INFO(priv, "HW Revision ID = 0x%X\n", rev_id);
>  	return iwl_read32(priv, CSR_HW_REV);
>  }
>  
hmm, I believe it is merge sequence issue, the IWL_DEBUG_INFO line has
benn remove all together in later patch. the information is being log in
the calling function, no need to log in "iwl_hw_detect"

Wey


