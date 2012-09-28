From: Joe Perches <joe@perches.com>
Subject: Re: [net-next PATCH 4/4] be2net: fixup log messages
Date: Fri, 28 Sep 2012 08:39:43 -0700
Message-ID: <1348846783.14262.10.camel@joe-AO722>
References: <1348843184-22214-1-git-send-email-sathya.perla@emulex.com>
	 <e698cd68-540d-4a7a-bd76-2e9c73ddf19c@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:40695 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757495Ab2I1Pjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2012 11:39:45 -0400
In-Reply-To: <e698cd68-540d-4a7a-bd76-2e9c73ddf19c@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-28 at 20:09 +0530, Sathya Perla wrote:
> Added and modified a few log messages mostly in probe path.

Trivial comment:

> diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
[]
> @@ -3797,6 +3802,23 @@ static bool be_reset_required(struct be_adapter *adapter)
>  	return be_find_vfs(adapter, ENABLED) > 0 ? false : true;
>  }
>  
> +static char *mc_name(struct be_adapter *adapter)
> +{
> +	if (adapter->function_mode & FLEX10_MODE)
> +		return "FLEX10";
> +	else if (adapter->function_mode & VNIC_MODE)
> +		return "vNIC";
> +	else if (adapter->function_mode & UMC_ENABLED)
> +		return "UMC";
> +	else
> +		return "";
> +}

Maybe something other than "" to identify this state
or add a space before or after the actual uses so that
the unprefixed state prints without 2 spaces.

Perhaps if you don't want to identify the non-virtual (?)
state:

static char *mc_name(struct be_adapter *adapter)
{
	if (adapter->function_mode & FLEX10_MODE)
		return " FLEX10";
	else if (adapter->function_mode & VNIC_MODE)
		return " vNIC";
	else if (adapter->function_mode & UMC_ENABLED)
		return " UMC";
	else
		return "";
}

[]

> @@ -3901,8 +3923,8 @@ static int __devinit be_probe(struct pci_dev *pdev,
>  
>  	be_cmd_query_port_name(adapter, &port_name);
>  
> -	dev_info(&pdev->dev, "%s: %s port %c\n", netdev->name, nic_name(pdev),
> -		 port_name);
> +	dev_info(&pdev->dev, "%s: %s %s port %c\n", nic_name(pdev),
> +		 func_name(adapter), mc_name(adapter), port_name);
>  
>  	return 0;

and:

	dev_info(&pdev->dev, "%s: %s%s port %c\n",
		 nic_name(pdev), func_name(adapter), mc_name(adapter),
		 port_name);
