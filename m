From: Joe Perches <joe@perches.com>
Subject: Re: [net 5/6] i40e: better return values
Date: Tue, 24 Sep 2013 04:34:46 -0700
Message-ID: <1380022486.3575.74.camel@joe-AO722>
References: <1380015910-25927-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1380015910-25927-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0235.hostedemail.com ([216.40.44.235]:60889 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750836Ab3IXLeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 07:34:50 -0400
In-Reply-To: <1380015910-25927-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 02:45 -0700, Jeff Kirsher wrote:

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
[]
> @@ -3339,9 +3345,7 @@ static u8 i40e_dcb_get_num_tc(struct i40e_dcbx_config *dcbcfg)
>  	/* Traffic class index starts from zero so
>  	 * increment to return the actual count
>  	 */
> -	num_tc++;
> -
> -	return num_tc;
> +	return num_tc++;

Ick.  post_increment problem.

	return ++num_tc;

There's nothing wrong with the original code
unless this is a bugfix which should be documented
better than "better return values".
