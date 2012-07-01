From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 06/10] {NET,IB}/mlx4: Add device managed flow
 steering firmware API
Date: Sun, 1 Jul 2012 15:29:41 +0300
Message-ID: <4FF042B5.1000303@mellanox.com>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com> <1341135823-29039-7-git-send-email-ogerlitz@mellanox.com> <20120701.033055.489908836962064737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roland@kernel.org>, <yevgenyp@mellanox.com>, <oren@mellanox.com>,
	<netdev@vger.kernel.org>, <hadarh@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:41293 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750811Ab2GAMaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 08:30:08 -0400
In-Reply-To: <20120701.033055.489908836962064737.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/1/2012 1:30 PM, David Miller wrote:
[...]
> @@ -136,6 +138,11 @@ module_param_array(port_type_array, int, &arr_argc, 0444);
>   MODULE_PARM_DESC(port_type_array, "Array of port types: HW_DEFAULT (0) is default "
>   				"1 for IB, 2 for Ethernet");
>   
> +static int mlx4_flow_steering_hash;
> +module_param_named(flow_steering_hash, mlx4_flow_steering_hash, int, 0444);
> +MODULE_PARM_DESC(flow_steering_hash,
> +		 "Flow steering hash function configuration. Config options: L2 = 0, L2_L3_L4 = 1 (default: L2).");
> +
>
> No module paramters, do it via ethtool or similar.
>

Dave,

We'll be handling the indentation, comments and other syntax issues you 
have pointed out
and submit V1, hopefully which would be clean from such errors.

Re the usage of the module param - as was pointed out in the change-log, 
please note that
this policy is **global** to the HCA, that is effects all the Ethernet 
(and down the road,
also IPoIB flow-steering, when we run a card with one IB port and one 
Eth port) net-devices
that relate to that device.

The module param is for mlx4_core and not for mlx4_en. In that respect, 
per net-device
ethtool directive wouldn't work, even when there is a dedicated firmware 
command that
allows changing this in run-time, which we don't have now.

My thinking was that once we have this command at hand, we can add 
sysfs/etc entry at
the mlx4_core level to provide a different hash function to the device. 
And for the
time being use the module param, makes sense?

Or.
