From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net 2/8] igb: fix vf lookup
Date: Wed, 8 Feb 2012 23:42:37 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F86242@ORSMSX106.amr.corp.intel.com>
References: <1328693798-27323-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1328693798-27323-3-git-send-email-jeffrey.t.kirsher@intel.com>
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
Received: from mga01.intel.com ([192.55.52.88]:26924 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757679Ab2BHXmx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 18:42:53 -0500
In-Reply-To: <1328693798-27323-3-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Kirsher, Jeffrey T
> Sent: Wednesday, February 08, 2012 1:37 AM
> To: davem@davemloft.net
> Cc: Rose, Gregory V; netdev@vger.kernel.org; gospo@redhat.com;
> sassmann@redhat.com; stable@vger.kernel.org; Kirsher, Jeffrey T
> Subject: [net 2/8] igb: fix vf lookup
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
> This is applicable to 3.2+ kernels.
> 
> CC: stable@vger.kernel.org
> Reported-by: David Ahern <daahern@cisco.com>
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Tested-by: Robert E Garrett <robertX.e.garrett@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
> b/drivers/net/ethernet/intel/igb/igb_main.c
> index e91d73c..94be6c3 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -5012,7 +5012,8 @@ static int igb_find_enabled_vfs(struct igb_adapter
> *adapter)
>  	vf_devfn = pdev->devfn + 0x80;
>  	pvfdev = pci_get_device(hw->vendor_id, device_id, NULL);
>  	while (pvfdev) {
> -		if (pvfdev->devfn == vf_devfn)
> +		if (pvfdev->devfn == vf_devfn &&
> +		    (pvfdev->bus->number >= pdev->bus->number))
>  			vfs_found++;
>  		vf_devfn += vf_stride;
>  		pvfdev = pci_get_device(hw->vendor_id,
> --
> 1.7.7.6

I'll fix this one too.  You start leaning on checkpatch and you get lazy I guess.

- Greg
