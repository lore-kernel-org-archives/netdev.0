From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 09/11] i40e: clean whole mac filter list
Date: Sat, 12 Dec 2015 18:30:47 +0300
Message-ID: <566C3DA7.4040508@cogentembedded.com>
References: <1449909213-33795-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1449909213-33795-10-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:35298 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbbLLPau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2015 10:30:50 -0500
Received: by lfdl133 with SMTP id l133so95511076lfd.2
        for <netdev@vger.kernel.org>; Sat, 12 Dec 2015 07:30:49 -0800 (PST)
In-Reply-To: <1449909213-33795-10-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/12/2015 11:33 AM, Jeff Kirsher wrote:

> From: Shannon Nelson <shannon.nelson@intel.com>
>
> Clean the whole mac filter list when resetting after an intermediate
> add or delete push to the firmware.  The code had evolved from using
> a list from the stack to a heap allocation, but the memset() didn't
> follow the change correctly.  This now cleans the whole list rather
> that just part of the first element.
>
> Change-ID: I4cd03d5a103b7407dd8556a3a231e800f2d6f2d5
> Reported-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_main.c | 18 ++++++++++--------
>   1 file changed, 10 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 35d787e..8ebf72b 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -1916,11 +1916,12 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
>
>   	/* Now process 'del_list' outside the lock */
>   	if (!list_empty(&tmp_del_list)) {
> +		int del_list_size;

    Need empty line after declaration.

>   		filter_list_len = pf->hw.aq.asq_buf_size /
>   			    sizeof(struct i40e_aqc_remove_macvlan_element_data);
> -		del_list = kcalloc(filter_list_len,
> -			    sizeof(struct i40e_aqc_remove_macvlan_element_data),
> -			    GFP_KERNEL);
> +		del_list_size = filter_list_len *
> +			    sizeof(struct i40e_aqc_remove_macvlan_element_data);
> +		del_list = kzalloc(del_list_size, GFP_KERNEL);
>   		if (!del_list) {
>   			i40e_cleanup_add_list(&tmp_add_list);
>
[...]

MBR, Sergei
