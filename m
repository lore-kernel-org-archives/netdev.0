From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000: Work around 82571 completion timout on Pseries
 HW
Date: Thu, 17 May 2007 20:47:00 -0400
Message-ID: <464CF784.70608@garzik.org>
References: <20070516085329.29131.120.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wenxiong@us.ibm.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43602 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759866AbXERArE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 20:47:04 -0400
In-Reply-To: <20070516085329.29131.120.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
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
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 49be393..830d851 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -819,6 +819,16 @@ e1000_reset(struct e1000_adapter *adapter)
>  		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
>  	}
>  
> +#if defined(CONFIG_PPC64) || defined(CONFIG_PPC)
> +#define E1000_GCR_DISABLE_TIMEOUT_MECHANISM 0x80000000
> +	if (adapter->hw.mac.type == e1000_82571) {
> +		/* work around pSeries hardware by disabling timeouts */
> +		u32 gcr = E1000_READ_REG(&adapter->hw, E1000_GCR);
> +		gcr |= E1000_GCR_DISABLE_TIMEOUT_MECHANISM;
> +		E1000_WRITE_REG(&adapter->hw, E1000_GCR, gcr);
> +	}
> +#endif

not applied.  based on the conversation, it sounds like this is not 
specific to PPC

	Jeff



