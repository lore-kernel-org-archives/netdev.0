From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next v2 14/17] i40e: enable PTP
Date: Fri, 10 Jan 2014 20:37:25 +0000
Message-ID: <1389386245.2025.98.camel@bwh-desktop.uk.level5networks.com>
References: <1389385839-11996-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1389385839-11996-15-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Jacob Keller <jacob.e.keller@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>,
	"Richard Cochran" <richardcochran@gmail.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60071 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbaAJUha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 15:37:30 -0500
In-Reply-To: <1389385839-11996-15-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-10 at 12:30 -0800, Jeff Kirsher wrote:
> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> New feature: Enable PTP support in the i40e driver.
> 
> Change-ID: I6a8e799f582705191f9583afb1b9231a8db96cc8
> Cc: Richard Cochran <richardcochran@gmail.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Matthew Vick <matthew.vick@intel.com>
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/Kconfig             |   1 +
>  drivers/net/ethernet/intel/i40e/Makefile       |   1 +
>  drivers/net/ethernet/intel/i40e/i40e.h         |  26 +
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  33 +-
>  drivers/net/ethernet/intel/i40e/i40e_main.c    |  47 +-
>  drivers/net/ethernet/intel/i40e/i40e_ptp.c     | 662 +++++++++++++++++++++++++
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c    |  53 ++
>  drivers/net/ethernet/intel/i40e/i40e_txrx.h    |   3 +
>  8 files changed, 824 insertions(+), 2 deletions(-)
>  create mode 100644 drivers/net/ethernet/intel/i40e/i40e_ptp.c
> 
> diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
> index 9fb2eb8..333bb54 100644
> --- a/drivers/net/ethernet/intel/Kconfig
> +++ b/drivers/net/ethernet/intel/Kconfig
[...]
> +void i40e_ptp_init(struct i40e_pf *pf)
> +{
> +	struct i40e_hw *hw = &pf->hw;
> +	struct net_device *netdev = pf->vsi[pf->lan_vsi]->netdev;
> +
> +	strncpy(pf->ptp_caps.name, netdev->name, sizeof(pf->ptp_caps.name));
[...]

I recommended using the *driver* name as the clock name.  The net device
doesn't even have a proper name at this point.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
