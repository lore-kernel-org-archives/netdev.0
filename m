From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] net: CNIC depends on PCI.
Date: Mon, 15 Jun 2009 11:24:58 -0700
Message-ID: <1245090298.12000.17.camel@HP1>
References: <20090615181244.GC30693@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: "Paul Mundt" <lethal@linux-sh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2042 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765026AbZFOSci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2009 14:32:38 -0400
In-Reply-To: <20090615181244.GC30693@linux-sh.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2009-06-15 at 11:12 -0700, Paul Mundt wrote:
> Even though this driver does shifty things with UIO to make it less
> obvious, it is still PCI dependent:
> 
> drivers/net/cnic.c:2395: error: implicit declaration of function 'pci_dev_get'
> make[3]: *** [drivers/net/cnic.o] Error 1
> make[2]: *** [drivers/net] Error 2
> 
> This fixes up the CONFIG_PCI=n case, primarily triggered on
> allmodconfig/allyesconfig builds:
> 
> Signed-off-by: Paul Mundt <lethal@linux-sh.org>
> Cc: Michael Chan <mchan@broadcom.com>

A similar patch is already in James' tree:

http://git.kernel.org/?p=linux/kernel/git/jejb/scsi-misc-2.6.git;a=commit;h=babdb788f7ec1a782a52240a5f6dae568f32565f

> 
> ---
> 
>  drivers/net/Kconfig |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 3b63831..f6d6888 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2272,8 +2272,7 @@ config BNX2
>  
>  config CNIC
>  	tristate "Broadcom CNIC support"
> -	depends on BNX2
> -	depends on UIO
> +	depends on PCI && BNX2 && UIO
>  	help
>  	  This driver supports offload features of Broadcom NetXtremeII
>  	  gigabit Ethernet cards.
> 


