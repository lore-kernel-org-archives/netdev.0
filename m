From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bonding-devel] [net-next-2.6 PATCH 2/3] bonding: check return
 value of nofitier when changing type
Date: Wed, 10 Mar 2010 14:47:10 -0800
Message-ID: <20100310144710.605ef033@nehalam>
References: <20100310202804.GC2834@psychotron.redhat.com>
	<20100310202935.GE2834@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51035 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757385Ab0CJWrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 17:47:52 -0500
In-Reply-To: <20100310202935.GE2834@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Mar 2010 21:29:35 +0100
Jiri Pirko <jpirko@redhat.com> wrote:

> diff --git a/net/core/dev.c b/net/core/dev.c
> index bcc490c..5de4a15 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1084,9 +1084,9 @@ void netdev_state_change(struct net_device *dev)
>  }
>  EXPORT_SYMBOL(netdev_state_change);
>  
> -void netdev_bonding_change(struct net_device *dev, unsigned long event)
> +int netdev_bonding_change(struct net_device *dev, unsigned long event)
>  {
> -	call_netdevice_notifiers(event, dev);
> +	return call_netdevice_notifiers(event, dev);
>  }
>  EXPORT_SYMBOL(netdev_bonding_change);
>  

I don't think all this pre-post stuff needed.
Since this is general (not just bonding) how about

int netdev_change_type(struct net_device *dev, int newtype)
{
	int ret, oldtype;

	if (dev->flags & IFF_UP)
		return -EBUSY;

	oldtype = dev->type;
	dev->type = newtype;
	ret = call_netdevice_notifier(NETDEV_CHANGETYPE, dev);
	ret = notifier_to_errno(ret);
	if (ret)
	     dev->type = oldtype;

	return ret;
}
	     
