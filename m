From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/4] net: introduce dev_mac_address_changed
Date: Mon, 13 Apr 2009 07:58:26 -0700
Message-ID: <20090413075826.7c8b758e@nehalam>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com>
	<20090413083729.GA23734@psychotron.englab.brq.redhat.com>
	<20090413083848.GB23734@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, davem@davemloft.net,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, kaber@trash.net,
	mschmidt@redhat.com, dada1@cosmosbay.com, ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34445 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751731AbZDMO7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 10:59:48 -0400
In-Reply-To: <20090413083848.GB23734@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Apr 2009 10:38:48 +0200
Jiri Pirko <jpirko@redhat.com> wrote:

> Introducing function dev_mac_address_changed which can be called from driver
> which changed his mac address to force notifiers to be called.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  include/linux/netdevice.h |    1 +
>  net/core/dev.c            |   12 ++++++++++++
>  2 files changed, 13 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 2e7783f..ff8db51 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1461,6 +1461,7 @@ extern int		dev_change_net_namespace(struct net_device *,
>  extern int		dev_set_mtu(struct net_device *, int);
>  extern int		dev_set_mac_address(struct net_device *,
>  					    struct sockaddr *);
> +extern void		dev_mac_address_changed(struct net_device *);
>  extern int		dev_hard_start_xmit(struct sk_buff *skb,
>  					    struct net_device *dev,
>  					    struct netdev_queue *txq);
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 91d792d..1adc89b 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3833,6 +3833,18 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
>  	return err;
>  }
>  
> +/**
> + *	dev_mac_address_changed - Notify Media Access Control Address changed
> + *	@dev: device
> + *
> + *	Notifies the change of the hardware (MAC) address of the device
> + */
> +void dev_mac_address_changed(struct net_device *dev)
> +{
> +	call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
> +}
> +EXPORT_SYMBOL(dev_mac_address_changed);
> +
>  /*
>   *	Perform the SIOCxIFxxx calls, inside read_lock(dev_base_lock)
>   */

The original version of this that I send, allowed notifiers to return
an error to block changing address (error would go back to application).
This is how other notifier hooks work (mtu, etc).

Why is dev_set_mac_address_changed called out separately, it should
be inside dev_set_mac_address. 

