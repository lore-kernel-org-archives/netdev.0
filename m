From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH 1/2] vmxnet3: remove unnecessary byteswapping in BAR
 writing macros
Date: Fri, 29 Oct 2010 11:17:31 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1010291115130.8381@sbhatewara-dev1.eng.vmware.com>
References: <1288235555-24675-1-git-send-email-harvey.harrison@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pv-drivers@vmware.com
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:36234 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752424Ab0J2SRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 14:17:31 -0400
In-Reply-To: <1288235555-24675-1-git-send-email-harvey.harrison@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Harvey,
Thanks for working on this. The change looks good.

Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>


On Wed, 27 Oct 2010, Harvey Harrison wrote:

> readl/writel swap to little-endian internally.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
>  drivers/net/vmxnet3/vmxnet3_int.h |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
> index 8a2f471..edf2288 100644
> --- a/drivers/net/vmxnet3/vmxnet3_int.h
> +++ b/drivers/net/vmxnet3/vmxnet3_int.h
> @@ -330,14 +330,14 @@ struct vmxnet3_adapter {
>  };
>  
>  #define VMXNET3_WRITE_BAR0_REG(adapter, reg, val)  \
> -	writel(cpu_to_le32(val), (adapter)->hw_addr0 + (reg))
> +	writel((val), (adapter)->hw_addr0 + (reg))
>  #define VMXNET3_READ_BAR0_REG(adapter, reg)        \
> -	le32_to_cpu(readl((adapter)->hw_addr0 + (reg)))
> +	readl((adapter)->hw_addr0 + (reg))
>  
>  #define VMXNET3_WRITE_BAR1_REG(adapter, reg, val)  \
> -	writel(cpu_to_le32(val), (adapter)->hw_addr1 + (reg))
> +	writel((val), (adapter)->hw_addr1 + (reg))
>  #define VMXNET3_READ_BAR1_REG(adapter, reg)        \
> -	le32_to_cpu(readl((adapter)->hw_addr1 + (reg)))
> +	readl((adapter)->hw_addr1 + (reg))
>  
>  #define VMXNET3_WAKE_QUEUE_THRESHOLD(tq)  (5)
>  #define VMXNET3_RX_ALLOC_THRESHOLD(rq, ring_idx, adapter) \
> -- 
> 1.7.1
> 
> 
