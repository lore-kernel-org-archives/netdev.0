From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: v2 [PATCH 2/2] de4x5: Remove developer debug feature about
	set/clear promisc
Date: Sat, 28 Jun 2008 11:52:41 -0600
Message-ID: <20080628175241.GA12265@colo.lackof.org>
References: <485BC7BA.60406@cn.fujitsu.com> <485F8332.6010203@trash.net> <485FA635.4090903@cn.fujitsu.com> <485FA962.5060704@trash.net> <485FB6D1.7000604@cn.fujitsu.com> <485FB8B1.8020000@trash.net> <4860478B.2080109@cn.fujitsu.com> <20080624051029.GB19434@colo.lackof.org> <48608887.6000102@cn.fujitsu.com> <48643F0C.9020408@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Patrick McHardy <kaber@trash.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>, kyle@parisc-linux.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:43153 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753287AbYF1Rwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Jun 2008 13:52:53 -0400
Content-Disposition: inline
In-Reply-To: <48643F0C.9020408@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 27, 2008 at 09:14:52AM +0800, Wang Chen wrote:
> >> If you want to remove a developer debug feature, please just submit
> >> a patch like usual to kyle and myself.
> >>
> > 
> > Is there any user space binary use these features?
> > case DE4X5_SET_PROM:
> > case DE4X5_CLR_PROM: 
> > If not, I will send a patch to remove them.

I spent about 20 minutes using both google and yahoo search trying
to find a use and did not. Given this driver has been visible
since about 1994, I'd expect such use to be visible.

> IFF_PROMISC flag shouldn't be set or cleared by drivers, because
> whether device be promisc mode is decided by how many upper layer
> callers being referenced to it.
> And the promisc changing feature of de4x5 ioctl is developer debug
> feature, we can remove it now.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
> diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
> index bc30c6e..617ef41 100644
> --- a/drivers/net/tulip/de4x5.c
> +++ b/drivers/net/tulip/de4x5.c
> @@ -5514,22 +5514,6 @@ de4x5_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
>  	netif_wake_queue(dev);                      /* Unlock the TX ring */
>  	break;
>  
> -    case DE4X5_SET_PROM:             /* Set Promiscuous Mode */
> -	if (!capable(CAP_NET_ADMIN)) return -EPERM;
> -	omr = inl(DE4X5_OMR);
> -	omr |= OMR_PR;
> -	outl(omr, DE4X5_OMR);
> -	dev->flags |= IFF_PROMISC;
> -	break;
> -
> -    case DE4X5_CLR_PROM:             /* Clear Promiscuous Mode */
> -	if (!capable(CAP_NET_ADMIN)) return -EPERM;
> -	omr = inl(DE4X5_OMR);
> -	omr &= ~OMR_PR;
> -	outl(omr, DE4X5_OMR);
> -	dev->flags &= ~IFF_PROMISC;
> -	break;
> -
>      case DE4X5_SAY_BOO:              /* Say "Boo!" to the kernel log file */
>  	if (!capable(CAP_NET_ADMIN)) return -EPERM;
>  	printk("%s: Boo!\n", dev->name);
> diff --git a/drivers/net/tulip/de4x5.h b/drivers/net/tulip/de4x5.h
> index f5f33b3..a6b7638 100644
> --- a/drivers/net/tulip/de4x5.h
> +++ b/drivers/net/tulip/de4x5.h
> @@ -1004,8 +1004,8 @@ struct de4x5_ioctl {
>  */
>  #define DE4X5_GET_HWADDR	0x01 /* Get the hardware address */
>  #define DE4X5_SET_HWADDR	0x02 /* Set the hardware address */
> -#define DE4X5_SET_PROM  	0x03 /* Set Promiscuous Mode */
> -#define DE4X5_CLR_PROM  	0x04 /* Clear Promiscuous Mode */
> +#define DE4X5_SET_PROM  	0x03 /* Obsoleted. Set Promiscuous Mode */
> +#define DE4X5_CLR_PROM  	0x04 /* Obsoleted. Clear Promiscuous Mode */

Please just remove them. If the kernel isn't going to provide the
functionality, I'd rather any apps that attempt to use it break
when they compile (vs later when they try to be run).


>  #define DE4X5_SAY_BOO	        0x05 /* Say "Boo!" to the kernel log file */
>  #define DE4X5_GET_MCA   	0x06 /* Get a multicast address */
>  #define DE4X5_SET_MCA   	0x07 /* Set a multicast address */

thanks,
grant
