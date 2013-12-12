From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 04/15] i40e: add netdev ops helper function
Date: Thu, 12 Dec 2013 18:27:09 +0400
Message-ID: <52A9C7BD.2010401@cogentembedded.com>
References: <1386852051-27907-1-git-send-email-jeffrey.t.kirsher@intel.com> <1386852051-27907-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Elizabeth Kappler <elizabeth.m.kappler@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:59432 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395Ab3LLO1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 09:27:09 -0500
Received: by mail-la0-f42.google.com with SMTP id ec20so365883lab.1
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 06:27:07 -0800 (PST)
In-Reply-To: <1386852051-27907-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12-12-2013 16:40, Jeff Kirsher wrote:

> From: Elizabeth Kappler <elizabeth.m.kappler@intel.com>

> Add a small helper function for assigning netdev_ops.
> trivial:
>    move include down
>    small nearby whitespace fixes for readablility

    Don't group unrelated changes in the different places of the file together 
into one patch please.

> Change-Id: Ib1c082a7bc9eedc1d3cfa5515720e4ef8f9f07cd
> Signed-off-by: Elizabeth Kappler <elizabeth.m.kappler@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e.h      |  2 +-
>   drivers/net/ethernet/intel/i40e/i40e_main.c | 13 ++++++++++++-
>   2 files changed, 13 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
> index 001d7cf..385d3ff 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e.h
> @@ -43,13 +43,13 @@
>   #include <linux/in.h>
>   #include <linux/ip.h>
>   #include <linux/tcp.h>
> -#include <linux/sctp.h>
>   #include <linux/pkt_sched.h>
>   #include <linux/ipv6.h>
>   #include <net/checksum.h>
>   #include <net/ip6_checksum.h>
>   #include <linux/ethtool.h>
>   #include <linux/if_vlan.h>
> +#include <linux/sctp.h>

    Why?

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 1ef311a..591a6e3 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -5849,6 +5849,15 @@ static const struct net_device_ops i40e_netdev_ops = {
>   };
>
>   /**
> + * i40e_assign_netdev_ops - Initialize netdev operations function pointers
> + * @dev: ptr to the netdev struct
> + **/

    Use a normal comment ending please, */.

> +static void i40e_assign_netdev_ops(struct net_device *dev)
> +{
> +	dev->netdev_ops = &i40e_netdev_ops;
> +}

    Frankly, I don't see much sense in such function. It only increases #LoC 
for no apparent reason.

> +
> +/**
>    * i40e_config_netdev - Setup the netdev flags
>    * @vsi: the VSI being configured
>    *
> @@ -5919,8 +5928,9 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
>   	/* Setup netdev TC information */
>   	i40e_vsi_config_netdev_tc(vsi, vsi->tc_config.enabled_tc);
>
> -	netdev->netdev_ops = &i40e_netdev_ops;
> +	i40e_assign_netdev_ops(netdev);
>   	netdev->watchdog_timeo = 5 * HZ;
> +
>   	i40e_set_ethtool_ops(netdev);
>
>   	return 0;
> @@ -7653,6 +7663,7 @@ static int __init i40e_init_module(void)
>   	pr_info("%s: %s - version %s\n", i40e_driver_name,
>   		i40e_driver_string, i40e_driver_version_str);
>   	pr_info("%s: %s\n", i40e_driver_name, i40e_copyright);
> +

    Unrelated whitespace change.

>   	i40e_dbg_init();
>   	return pci_register_driver(&i40e_driver);
>   }

WBR, Sergei
