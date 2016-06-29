From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 02/16] i40e: add hw struct local variable
Date: Wed, 29 Jun 2016 13:00:39 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4E73F2@AcuExch.aculab.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1467175262-54719-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.187]:61356 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbcF2NCK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 09:02:10 -0400
In-Reply-To: <1467175262-54719-3-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher
> Sent: 29 June 2016 05:41
> From: Mitch Williams <mitch.a.williams@intel.com>
> 
> This function uses the i40e_hw struct all over the place, so why doesn't
> it keep a pointer to the struct? Add this pointer as a local variable
> and use it consistently throughout the function.
> 
> Change-ID: I10eb688fe40909433fcb8ac7ac891cef67445d72
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c | 79 +++++++++++++++--------------
>  1 file changed, 41 insertions(+), 38 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 734cba6..9a26ecc 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -1840,6 +1840,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
>  {
>  	struct list_head tmp_del_list, tmp_add_list;
>  	struct i40e_mac_filter *f, *ftmp, *fclone;
> +	struct i40e_hw *hw = &vsi->back->hw;
>  	bool promisc_forced_on = false;
>  	bool add_happened = false;
>  	int filter_list_len = 0;
> @@ -1920,7 +1921,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
>  	if (!list_empty(&tmp_del_list)) {
>  		int del_list_size;
> 
> -		filter_list_len = pf->hw.aq.asq_buf_size /
> +		filter_list_len = hw->aq.asq_buf_size /
...

I suspect you've just made the compiler use separate registers for
pf and hw.
This could easily cause additional register spills to/from stack.

	David
