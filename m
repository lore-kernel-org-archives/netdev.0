From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [PATCH net-next] net/fm10k: Avoid double setting of NETIF_F_SG
 for the HW encapsulation feature mask
Date: Fri, 7 Nov 2014 21:57:10 +0000
Message-ID: <D0827E2E.5ED4E%matthew.vick@intel.com>
References: <1415265664-10738-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:48291 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751766AbaKGV5N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 16:57:13 -0500
In-Reply-To: <1415265664-10738-1-git-send-email-ogerlitz@mellanox.com>
Content-Language: en-US
Content-ID: <CF7DE2D872703944B57D03EC80DB5DF8@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/6/14, 1:21 AM, "Or Gerlitz" <ogerlitz@mellanox.com> wrote:

>The networking core does it for the driver during registration time.
>
>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>---
> drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |    5 ++---
> 1 files changed, 2 insertions(+), 3 deletions(-)
>
>diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
>b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
>index 8811364..2b17cd8 100644
>--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
>+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
>@@ -1414,13 +1414,12 @@ struct net_device *fm10k_alloc_netdev(void)
> 	dev->vlan_features |= dev->features;
> 
> 	/* configure tunnel offloads */
>-	dev->hw_enc_features = NETIF_F_IP_CSUM |
>+	dev->hw_enc_features |= NETIF_F_IP_CSUM |
> 			       NETIF_F_TSO |
> 			       NETIF_F_TSO6 |
> 			       NETIF_F_TSO_ECN |
> 			       NETIF_F_GSO_UDP_TUNNEL |
>-			       NETIF_F_IPV6_CSUM |
>-			       NETIF_F_SG;
>+			       NETIF_F_IPV6_CSUM;
> 
> 	/* we want to leave these both on as we cannot disable VLAN tag
> 	 * insertion or stripping on the hardware since it is contained

Good catch, Or! Thank you for taking care of this!

Someone can correct me if I'm mistaken (I thought checkpatch would
complain about this, but it doesn't seem to be), but I believe the start
of the lines should match up like they are for the dev->features. Would
you like to submit a V2 with this change or would you like me to do it
(giving you credit via your Reported-by)?

Cheers,
Matthew
