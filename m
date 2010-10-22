From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH 3/3] vmxnet3: fix typo setting confPA
Date: Fri, 22 Oct 2010 10:31:58 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1010221030530.9726@sbhatewara-dev1.eng.vmware.com>
References: <1287720334-15469-1-git-send-email-harvey.harrison@gmail.com> <1287720334-15469-3-git-send-email-harvey.harrison@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:47668 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756447Ab0JVRb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 13:31:58 -0400
In-Reply-To: <1287720334-15469-3-git-send-email-harvey.harrison@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




On Thu, 21 Oct 2010, Harvey Harrison wrote:

> It's a le64, not a le32, typo in one place only.
>

Sure it is. Thanks for the change.

Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

 
> Noticed by sparse:
> drivers/net/vmxnet3/vmxnet3_drv.c:2668:52: warning: incorrect type in assignment (different base types)
> drivers/net/vmxnet3/vmxnet3_drv.c:2668:52:    expected restricted __le64 [usertype] confPA
> drivers/net/vmxnet3/vmxnet3_drv.c:2668:52:    got restricted __le32 [usertype] <noident>
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
>  drivers/net/vmxnet3/vmxnet3_drv.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
> index 2ea4b81..e3658e1 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -2665,7 +2665,7 @@ vmxnet3_resume(struct device *device)
>  	adapter->shared->devRead.pmConfDesc.confVer = cpu_to_le32(1);
>  	adapter->shared->devRead.pmConfDesc.confLen = cpu_to_le32(sizeof(
>  								  *pmConf));
> -	adapter->shared->devRead.pmConfDesc.confPA = cpu_to_le32(virt_to_phys(
> +	adapter->shared->devRead.pmConfDesc.confPA = cpu_to_le64(virt_to_phys(
>  								 pmConf));
>  
>  	netif_device_attach(netdev);
> -- 
> 1.7.1
> 
> 
