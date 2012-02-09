From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net v2 3/8] ixgbe: fix vf lookup
Date: Thu, 9 Feb 2012 16:27:51 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F86E27@ORSMSX106.amr.corp.intel.com>
References: <1328780061-25000-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1328780061-25000-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:44410 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750978Ab2BIQ17 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 11:27:59 -0500
In-Reply-To: <1328780061-25000-4-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Kirsher, Jeffrey T
> Sent: Thursday, February 09, 2012 1:34 AM
> To: davem@davemloft.net
> Cc: Rose, Gregory V; netdev@vger.kernel.org; gospo@redhat.com;
> sassmann@redhat.com; stable@vger.kernel.org; Kirsher, Jeffrey T
> Subject: [net v2 3/8] ixgbe: fix vf lookup
> 
> From: Greg Rose <gregory.v.rose@intel.com>
> 
> Recent addition of code to find already allocated VFs failed to take
> account that systems with 2 or more multi-port SR-IOV capable controllers
> might have already enabled VFs.  Make sure that the VFs the function is
> finding are actually subordinate to the particular instance of the adapter
> that is looking for them and not subordinate to some device that has
> previously enabled SR-IOV.
> 
> This bug exists in 3.2 stable as well as 3.3 release candidates.
> 
> CC: stable@vger.kernel.org
> Reported-by: David Ahern <daahern@cisco.com>
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Tested-by: Robert E Garrett <robertX.e.garrett@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> index 8d8cdbc..b982710 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> @@ -67,7 +67,8 @@ static int ixgbe_find_enabled_vfs(struct ixgbe_adapter
> *adapter)
>  	vf_devfn = pdev->devfn + 0x80;
>  	pvfdev = pci_get_device(IXGBE_INTEL_VENDOR_ID, device_id, NULL);
>  	while (pvfdev) {
> -		if (pvfdev->devfn == vf_devfn)
> +		if (pvfdev->devfn == vf_devfn &&
> +		    (pvfdev->bus->number >= pdev->bus->number))
>  			vfs_found++;
>  		vf_devfn += 2;
>  		pvfdev = pci_get_device(IXGBE_INTEL_VENDOR_ID,
> --
> 1.7.7.6

It still has unneeded parenthesis around the second half of the if expression.  I'll fix that up in the next series of patches.  Same for the igb driver.

- Greg
