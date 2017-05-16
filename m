From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [PATCH net v1] net/smc: Add warning about remote memory exposure
Date: Tue, 16 May 2017 17:04:00 +0200
Message-ID: <f5f60ab0-52c6-e8f2-4654-bc52658c93b0@linux.vnet.ibm.com>
References: <20170516065138.24789-1-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, iinux-rdma@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>
To: Leon Romanovsky <leon@kernel.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:55506 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753128AbdEPPEM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 11:04:12 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4GF47TQ018610
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 11:04:11 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2ag21rphpe-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 11:04:10 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Tue, 16 May 2017 16:04:04 +0100
In-Reply-To: <20170516065138.24789-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/2017 08:51 AM, Leon Romanovsky wrote:
> From: Christoph Hellwig <hch@lst.de>
> 
> The driver explicitly bypasses APIs to register all memory once a
> connection is made, and thus allows remote access to memory.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Leon Romanovsky <leon@kernel.org>
> ---
> Dave,
> Can you please forward this patch to stable?
> Thanks
> ---
>  Changes from v0:
>   * Remove BROKEN Kconfig option as a followup of this discussion
>     https://patchwork.ozlabs.org/patch/760454/
>   * Refine commit message
> ---
>  net/smc/Kconfig | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/net/smc/Kconfig b/net/smc/Kconfig
> index c717ef0896aa..33954852f3f8 100644
> --- a/net/smc/Kconfig
> +++ b/net/smc/Kconfig
> @@ -8,6 +8,10 @@ config SMC
>  	  The Linux implementation of the SMC-R solution is designed as
>  	  a separate socket family SMC.
> 
> +	  Warning: SMC will expose all memory for remote reads and writes
> +	  once a connection is established.  Don't enable this option except
> +	  for tightly controlled lab environment.
> +
>  	  Select this option if you want to run SMC socket applications
> 
>  config SMC_DIAG
> --
> 2.12.2
> 

Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
