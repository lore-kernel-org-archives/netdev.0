From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
Date: Mon, 23 Mar 2015 23:46:54 +0000
Message-ID: <87618083B2453E4A8714035B62D6799250274730@FMSMSX105.amr.corp.intel.com>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com>
 <1427050887-19412-5-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>
To: Vlad Zolotarov <vladz@cloudius-systems.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28705 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752192AbbCWXrA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 19:47:00 -0400
In-Reply-To: <1427050887-19412-5-git-send-email-vladz@cloudius-systems.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Vlad Zolotarov
>Sent: Sunday, March 22, 2015 12:01 PM
>
>Subject: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
>
>   - Added a new API version support.
>   - Added the query implementation in the ixgbevf.
>
>Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
>---
>New in v6:
>   - Add a proper return code when an operation is blocked by PF.
>
>New in v3:
>   - Adjusted to the new interface IXGBE_VF_GET_RETA command.
>   - Added a proper support for x550 devices.
>
>New in v1 (compared to RFC):
>   - Use "if-else" statement instead of a "switch-case" for a single option case
>     (in ixgbevf_get_reta()).
>---
> drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  4 +-
> drivers/net/ethernet/intel/ixgbevf/mbx.h          |  8 ++
> drivers/net/ethernet/intel/ixgbevf/vf.c           | 92 +++++++++++++++++++++++
> drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
> 4 files changed, 104 insertions(+), 1 deletion(-)
>
>diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>index 4ee15ad..4787fcf 100644
>--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>@@ -2030,7 +2030,8 @@ static void ixgbevf_init_last_counter_stats(struct ixgbevf_adapter *adapter)
> static void ixgbevf_negotiate_api(struct ixgbevf_adapter *adapter)
> {
> 	struct ixgbe_hw *hw = &adapter->hw;
>-	int api[] = { ixgbe_mbox_api_11,
>+	int api[] = { ixgbe_mbox_api_12,
>+		      ixgbe_mbox_api_11,
> 		      ixgbe_mbox_api_10,
> 		      ixgbe_mbox_api_unknown };
> 	int err = 0, idx = 0;
>@@ -3712,6 +3713,7 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
> 
> 	switch (adapter->hw.api_version) {
> 	case ixgbe_mbox_api_11:
>+	case ixgbe_mbox_api_12:
> 		max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
> 		break;
> 	default:

You need another case for ixgbe_mbox_api_12 in ixgbevf_set_num_queues(), otherwise the driver will load with a single queue.

Thanks,
Emil
