From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: Request for review on Hyper-V virtual network driver
Date: Thu, 9 Jun 2011 14:56:41 -0700
Message-ID: <20110609145641.cf245229.randy.dunlap@oracle.com>
References: <1307654865-30326-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hjanssen@microsoft.com, kys@microsoft.com, gregkh@suse.de,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:37961 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756135Ab1FIV44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 17:56:56 -0400
In-Reply-To: <1307654865-30326-1-git-send-email-haiyangz@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  9 Jun 2011 14:27:45 -0700 Haiyang Zhang wrote:

> To network maintainers,
> 
> Over the last several months we have addressed all the known issues in our
> Hyper-V virtual network driver. We are very keen on getting this driver out
> of the staging area. To that end, we would like to request you to review
> this code. 
> 
> Thanks,
> 	Haiyang
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> ---
>  drivers/net/Kconfig               |    2 +
>  drivers/net/Makefile              |    1 +
>  drivers/net/hyperv/Kconfig        |   10 +
>  drivers/net/hyperv/Makefile       |    4 +
>  drivers/net/hyperv/hyperv_net.h   | 1057 +++++++++++++++++++++++++++++++++++++
>  drivers/net/hyperv/netvsc.c       | 1014 +++++++++++++++++++++++++++++++++++
>  drivers/net/hyperv/netvsc_drv.c   |  473 +++++++++++++++++
>  drivers/net/hyperv/rndis_filter.c |  830 +++++++++++++++++++++++++++++
>  drivers/staging/hv/Kconfig        |    7 -
>  drivers/staging/hv/Makefile       |    2 -
>  drivers/staging/hv/hyperv_net.h   | 1057 -------------------------------------
>  drivers/staging/hv/netvsc.c       | 1015 -----------------------------------
>  drivers/staging/hv/netvsc_drv.c   |  474 -----------------
>  drivers/staging/hv/rndis_filter.c |  831 -----------------------------
>  14 files changed, 3391 insertions(+), 3386 deletions(-)
>  create mode 100644 drivers/net/hyperv/Kconfig
>  create mode 100644 drivers/net/hyperv/Makefile
>  create mode 100644 drivers/net/hyperv/hyperv_net.h
>  create mode 100644 drivers/net/hyperv/netvsc.c
>  create mode 100644 drivers/net/hyperv/netvsc_drv.c
>  create mode 100644 drivers/net/hyperv/rndis_filter.c
>  delete mode 100644 drivers/staging/hv/hyperv_net.h
>  delete mode 100644 drivers/staging/hv/netvsc.c
>  delete mode 100644 drivers/staging/hv/netvsc_drv.c
>  delete mode 100644 drivers/staging/hv/rndis_filter.c
> 
> diff --git a/drivers/net/hyperv/Kconfig b/drivers/net/hyperv/Kconfig
> new file mode 100644
> index 0000000..62dccf6
> --- /dev/null
> +++ b/drivers/net/hyperv/Kconfig
> @@ -0,0 +1,10 @@
> +if HYPERV
> +
> +config HYPERV_NET
> +	tristate "Microsoft Hyper-V virtual network driver"
> +	depends on NET

Drop line above -- it's no longer needed since drivers/net/Kconfig
handles that.

> +	default HYPERV
> +	help
> +	  Select this option to enable the Hyper-V virtual network driver.
> +
> +endif


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
