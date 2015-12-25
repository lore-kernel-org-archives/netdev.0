From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [net-next 8/9] ixgbe: fix write to VLVFB in
 ixgbe_clear_vf_vlans()
Date: Fri, 25 Dec 2015 15:33:58 +0000
Message-ID: <87618083B2453E4A8714035B62D67992504F2FF5@FMSMSX105.amr.corp.intel.com>
References: <1451021396-68858-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1451021396-68858-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59516 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751186AbbLYPeO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2015 10:34:14 -0500
In-Reply-To: <1451021396-68858-9-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Kirsher, Jeffrey T
>Sent: Thursday, December 24, 2015 9:30 PM
>To: davem@davemloft.net
>Cc: Tantilov, Emil S; netdev@vger.kernel.org; nhorman@redhat.com;
>sassmann@redhat.com; jogreene@redhat.com; Kirsher, Jeffrey T
>Subject: [net-next 8/9] ixgbe: fix write to VLVFB in ixgbe_clear_vf_vlans()
>
>From: Emil Tantilov <emil.s.tantilov@intel.com>
>
>Fix the write to the VLVFB register in ixgbe_clear_vf_vlans() where
>word is the actual offset of the register and not the index for the
>IXGBE_VLVFB macro.
>
>This was causing PCI AER errors on my system.
>
>Fixes: 4c7f35f679f592804736f9303051257de2c9f021
>("ixgbe: Clean stale VLANs when changing port VLAN or resetting")
>
>Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
>Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
>Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>---
> drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>index eeff3d0..fd918da 100644
>--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>@@ -640,7 +640,7 @@ update_vlvf:
> 		IXGBE_WRITE_REG(hw, IXGBE_VLVF(i), 0);
> update_vlvfb:
> 		/* clear pool bits */
>-		IXGBE_WRITE_REG(hw, IXGBE_VLVFB(word), vlvfb);
>+		IXGBE_WRITE_REG(hw, word, vlvfb);
> 	}
> }
>
>--
>2.5.0

Alex submitted another patch for this function that should've been
used instead as it also resolves an issue with the mask.

Thanks,
Emil 
