From: reinette chatre <reinette.chatre@intel.com>
Subject: Re: linux-next: manual merge of the net tree with the
 wireless-current tree
Date: Wed, 12 May 2010 09:15:43 -0700
Message-ID: <1273680943.2370.9533.camel@rchatre-DESK>
References: <20100512121539.8956720a.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:65224 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755797Ab0ELQPp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 May 2010 12:15:45 -0400
In-Reply-To: <20100512121539.8956720a.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On Tue, 2010-05-11 at 19:15 -0700, Stephen Rothwell wrote:
> Today's linux-next merge of the net tree got a conflict in
> drivers/net/wireless/iwlwifi/iwl-dev.h between commit
> 562db532760827f6ce30801a08e6b568848bc9f2 ("iwlagn: wait for
> asynchronous
> firmware loading") from the wireless-current tree and commit
> ee525d13f501baeaa33209620398adaf0a820629 ("iwlwifi: move 3945 specific
> data into union") from the net tree.
> 
> Just context changes. I fixed it up (see below) and can carry the fix
> for
> a while.
> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> 
> diff --cc drivers/net/wireless/iwlwifi/iwl-dev.h
> index 4d4c651,58c69a5..0000000
> --- a/drivers/net/wireless/iwlwifi/iwl-dev.h
> +++ b/drivers/net/wireless/iwlwifi/iwl-dev.h
> @@@ -1304,12 -1274,6 +1274,8 @@@ struct iwl_priv 
>         struct delayed_work alive_start;
>         struct delayed_work scan_check;
>   
>  +      struct completion firmware_loading_complete;
>  +

Please note that this member of iwl_priv is now located in two
places ... here and also in the device specific union a few lines up
inside the _agn struct. In the code it is indeed the one in the _agn
struct that is being used (see usage in iwl-agn.c), so adding this line
is not necessary.

This should not cause any problems with driver operation and can
probably remain as such if indeed it is cleaned up somewhere else before
it hits you again or linux-2.6.

> -       /*For 3945 only*/
> -       struct delayed_work thermal_periodic;
> -       struct delayed_work rfkill_poll;
> - 
>         /* TX Power */
>         s8 tx_power_user_lmt;
>         s8 tx_power_device_lmt;
> 
> 

Reinette


