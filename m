From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v2 01/14] i40e: don't degrade __le16
Date: Wed, 26 Aug 2015 15:57:29 -0700
Message-ID: <1440629849.11525.58.camel@perches.com>
References: <1440629373-21287-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1440629373-21287-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0103.hostedemail.com ([216.40.44.103]:32934 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751363AbbHZW5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 18:57:33 -0400
In-Reply-To: <1440629373-21287-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-08-26 at 15:49 -0700, Jeff Kirsher wrote:

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
[]
> @@ -2106,11 +2106,12 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
[]
>  		dev_err(&pf->pdev->dev,
>  			"VF %d has already configured VLAN filters and the administrator is requesting a port VLAN override.\nPlease unload and reload the VF driver for this change to take effect.\n",
>  			vf_id);

Unrelated trivia:

This might be better with separate dev_err calls so
there is a consistent prefix in the logging output.

		dev_err(&pf->pdev->dev,
 			"VF %d has already configured VLAN filters and the administrator is requesting a port VLAN override.\n",
 			vf_id);
		dev_err(&pf->pdev->dev,
			"Please unload and reload the VF driver for this change to take effect.\n");
