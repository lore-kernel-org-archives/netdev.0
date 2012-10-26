From: "Kicinski, Jakub" <jakub.kicinski@intel.com>
Subject: RE: [net-next 10/14] ixgbevf: make sure probe fails on MSI-X enable
 error
Date: Fri, 26 Oct 2012 12:43:12 +0000
Message-ID: <4F2EF616F787D840B1215485A0B91D1E5EF3AD@IRSMSX103.ger.corp.intel.com>
References: <1351252702-16532-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1351252702-16532-11-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:20796 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932591Ab2JZMox convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 08:44:53 -0400
In-Reply-To: <1351252702-16532-11-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Jakub Kicinski <jakub.kicinski@intel.com>
> 
> This driver cannot work without MSI-X interrupts so there is no mechanism to
> fall back to.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@intel.com>
> Acked-by: Greg Rose <gregory.v.rose@intel.com>
> Tested-by: Sibai Li <sibai.li@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 24 +++++++++++------------
>  1 file changed, 11 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index b5979ba..7ceccff 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
[...]
> @@ -1858,7 +1856,7 @@ static int ixgbevf_set_interrupt_capability(struct
> ixgbevf_adapter *adapter)
>  	for (vector = 0; vector < v_budget; vector++)
>  		adapter->msix_entries[vector].entry = vector;
> 
> -	ixgbevf_acquire_msix_vectors(adapter, v_budget);
> +	err = ixgbevf_acquire_msix_vectors(adapter, v_budget);
> 
>  	err = netif_set_real_num_tx_queues(netdev, adapter->num_tx_queues);
>  	if (err)

This is clearly wrong. My change was overtaken by:

commit 91e2b89b04d3f568dc4ec99f242a4a742061e399
Author: Greg Rose <gregory.v.rose@intel.com>
Date:   Wed Oct 3 00:57:23 2012 +0000

    ixgbevf: Set the netdev number of Tx queues

Please drop this patch, I'll resend a fixed version to Greg.

   -- Kuba
---------------------------------------------------------------------
Intel Technology Poland sp. z o.o.
z siedziba w Gdansku
ul. Slowackiego 173
80-298 Gdansk

Sad Rejonowy Gdansk Polnoc w Gdansku, 
VII Wydzial Gospodarczy Krajowego Rejestru Sadowego, 
numer KRS 101882

NIP 957-07-52-316
Kapital zakladowy 200.000 zl

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
