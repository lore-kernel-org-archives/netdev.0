From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next v2 06/16] i40e: ignore duplicate port VLAN requests
Date: Wed, 15 Jul 2015 22:24:50 +0300
Message-ID: <55A6B382.1050004@cogentembedded.com>
References: <1436923840-24455-1-git-send-email-jeffrey.t.kirsher@intel.com> <1436923840-24455-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:35568 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbbGOTYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 15:24:55 -0400
Received: by lblf12 with SMTP id f12so30978852lbl.2
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 12:24:53 -0700 (PDT)
In-Reply-To: <1436923840-24455-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07/15/2015 04:30 AM, Jeff Kirsher wrote:

> From: Mitch Williams <mitch.a.williams@intel.com>

> If user attempts to set a port VLAN on a VF that already has the same
> port VLAN configured, the driver will go through a completely
> unnecessary flurry of filter removals and filter adds. Just check for
> this condition and return success instead of doing a bunch of busywork.

> Change-ID: Ia1a9e83e6ed48b3f4658bc20dfc6af0cf525d54a
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Tested-by: Jim Young <james.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 4 ++++
>   1 file changed, 4 insertions(+)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> index 23f95cd..433e803 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> @@ -2088,6 +2088,10 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
>   		goto error_pvid;
>   	}
>
> +	if (vsi->info.pvid == (vlan_id | (qos << I40E_VLAN_PRIORITY_SHIFT)))

    Parens around | not necessary (strictly speaking, around << too but gcc 
may have another opinion and warn about the parens).

[...]

MBR, Sergei
