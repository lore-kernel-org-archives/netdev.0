From: "Sharon, Sara" <sara.sharon@intel.com>
Subject: RE: [PATCH] iwlwifi:Add increment statement for a  for loop in the
 function iwl_pcie_rx_allocator
Date: Wed, 8 Jul 2015 14:17:42 +0000
Message-ID: <84271B8B681983469E84120965EB1B04349FDC8D@HASMSX106.ger.corp.intel.com>
References: <1436363071-548-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"Altman, Avri" <avri.altman@intel.com>,
	"Kaufman, Liad" <liad.kaufman@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Nicholas Krause' <xerofoify@gmail.com>,
	"Berg, Johannes" <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436363071-548-1-git-send-email-xerofoify@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This removes the incrementing of the variable i at the end of the
> function iwl_pcie_rx_allocator's for loop into the for loop statement
> by adding the increment statement of i++ at the end of the for loop
> declaration in order to improve readablitiy of this for loop's
> declaration in the function iwl_pcie_rx_allocator.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/wireless/iwlwifi/pcie/rx.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/iwlwifi/pcie/rx.c
> b/drivers/net/wireless/iwlwifi/pcie/rx.c
> index a3fbaa0..a26609c 100644
> --- a/drivers/net/wireless/iwlwifi/pcie/rx.c
> +++ b/drivers/net/wireless/iwlwifi/pcie/rx.c
> @@ -441,7 +441,7 @@ static void iwl_pcie_rx_allocator(struct iwl_trans
> *trans)
>  		list_replace_init(&rba->rbd_empty, &local_empty);
>  		spin_unlock(&rba->lock);
> 
> -		for (i = 0; i < RX_CLAIM_REQ_ALLOC;) {
> +		for (i = 0; i < RX_CLAIM_REQ_ALLOC; i++) {
>  			struct iwl_rx_mem_buffer *rxb;
>  			struct page *page;
> 

This is wrong in the error flows. Please note the continue statements in the code.
It is important that the loop counter will not be incremented in those cases, or your kernel will panic.

> @@ -478,7 +478,6 @@ static void iwl_pcie_rx_allocator(struct iwl_trans
> *trans)
> 
>  			/* move the allocated entry to the out list */
>  			list_move(&rxb->list, &local_allocated);
> -			i++;
>  		}
> 
>  		spin_lock(&rba->lock);
> --
> 2.1.4

---------------------------------------------------------------------
A member of the Intel Corporation group of companies

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
