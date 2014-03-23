From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [net-next 15/16] igb: Fix Null-pointer dereference in
 igb_reset_q_vector
Date: Sun, 23 Mar 2014 15:31:25 +0100
Message-ID: <20140323143125.GC5028@cpaasch-mac>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <0082c389c1d6488cb5cf473ff1bc26e2@UCL-MBX03.OASIS.UCLOUVAIN.BE>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:44371 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbaCWObb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 10:31:31 -0400
Content-Disposition: inline
In-Reply-To: <0082c389c1d6488cb5cf473ff1bc26e2@UCL-MBX03.OASIS.UCLOUVAIN.BE>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/03/14 - 12:10:05, Jeff Kirsher wrote:
> From: Christoph Paasch <christoph.paasch@uclouvain.be>
> 
> When igb_set_interrupt_capability() calls
> igb_reset_interrupt_capability() (e.g., because CONFIG_PCI_MSI is unset),
> num_q_vectors has been set but no vector has yet been allocated.
> 
> igb_reset_interrupt_capability() will then call igb_reset_q_vector,
> which assumes that the vector is allocated. As this is not the case, we
> are accessing a NULL-pointer.
> 
> This patch fixes it by checking that q_vector is indeed different from
> NULL.
> 
> Fixes: 02ef6e1d0b0023 (igb: Fix queue allocation method to accommodate changing during runtime)
> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Hello Jeff,

shouldn't this one rather be for 'net' instead of 'net-next'? Because
02ef6e1d0b0023 is part of 3.14-rc1.


Cheers,
Christoph


> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index e8b4f7b..6acf787 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -1035,6 +1035,12 @@ static void igb_reset_q_vector(struct igb_adapter *adapter, int v_idx)
>  {
>  	struct igb_q_vector *q_vector = adapter->q_vector[v_idx];
>  
> +	/* Coming from igb_set_interrupt_capability, the vectors are not yet
> +	 * allocated. So, q_vector is NULL so we should stop here.
> +	 */
> +	if (!q_vector)
> +		return;
> +
>  	if (q_vector->tx.ring)
>  		adapter->tx_ring[q_vector->tx.ring->queue_index] = NULL;
>  
> -- 
> 1.8.3.1
> 
