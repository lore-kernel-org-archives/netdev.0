From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] e1000: Work around 82571 completion timout on Pseries HW
Date: Wed, 16 May 2007 19:43:27 -0500
Message-ID: <495A2DE1-775D-4DFC-9C1C-4644AA5A040B@kernel.crashing.org>
References: <20070516085329.29131.120.stgit@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, wenxiong@us.ibm.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:56100 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755714AbXEQApP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 20:45:15 -0400
In-Reply-To: <20070516085329.29131.120.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On May 16, 2007, at 3:53 AM, Auke Kok wrote:

> Our 82571 (first PCI-E hardware) causes P-Series hardware to throw
> issues. Disabling PCI-E completion timeouts in our NIC resolves
> the issue.
>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Wen Xiong <wenxiong@us.ibm.com>
> ---
>
>  drivers/net/e1000/e1000_main.c |   10 ++++++++++
>  1 files changed, 10 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/ 
> e1000_main.c
> index 49be393..830d851 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -819,6 +819,16 @@ e1000_reset(struct e1000_adapter *adapter)
>  		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
>  	}
>
> +#if defined(CONFIG_PPC64) || defined(CONFIG_PPC)

If this is really on need on pseries HW this should be #ifdef  
CONFIG_PPC_PSERIES.  No reason to force this on all PPC.

> +#define E1000_GCR_DISABLE_TIMEOUT_MECHANISM 0x80000000
> +	if (adapter->hw.mac.type == e1000_82571) {
> +		/* work around pSeries hardware by disabling timeouts */
> +		u32 gcr = E1000_READ_REG(&adapter->hw, E1000_GCR);
> +		gcr |= E1000_GCR_DISABLE_TIMEOUT_MECHANISM;
> +		E1000_WRITE_REG(&adapter->hw, E1000_GCR, gcr);
> +	}
> +#endif
> +
>  	/* Enable h/w to recognize an 802.1Q VLAN Ethernet packet */
>  	E1000_WRITE_REG(&adapter->hw, VET, ETHERNET_IEEE_VLAN_TYPE);
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

