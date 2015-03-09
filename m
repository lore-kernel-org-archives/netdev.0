From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next] switchdev: use gpl variant of symbol export
Date: Mon, 09 Mar 2015 10:11:46 -0700
Message-ID: <54FDD452.1020008@gmail.com>
References: <1425893184-1738-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sfeldma@gmail.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:43745 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932278AbbCIRMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 13:12:24 -0400
Received: by pdjp10 with SMTP id p10so59131170pdj.10
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 10:12:24 -0700 (PDT)
In-Reply-To: <1425893184-1738-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/15 02:26, Jiri Pirko wrote:
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Note: this still won't prevent vendors from doing trampoline drivers,
but at least they will have to make their shim be appropriately marked
as GPL or compatible when doing this as a module.

> ---
>  net/switchdev/switchdev.c | 24 ++++++++++++------------
>  1 file changed, 12 insertions(+), 12 deletions(-)
> 
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 19e4e72..aba6aa2 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -33,7 +33,7 @@ int netdev_switch_parent_id_get(struct net_device *dev,
>  		return -EOPNOTSUPP;
>  	return ops->ndo_switch_parent_id_get(dev, psid);
>  }
> -EXPORT_SYMBOL(netdev_switch_parent_id_get);
> +EXPORT_SYMBOL_GPL(netdev_switch_parent_id_get);
>  
>  /**
>   *	netdev_switch_port_stp_update - Notify switch device port of STP
> @@ -52,7 +52,7 @@ int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
>  	WARN_ON(!ops->ndo_switch_parent_id_get);
>  	return ops->ndo_switch_port_stp_update(dev, state);
>  }
> -EXPORT_SYMBOL(netdev_switch_port_stp_update);
> +EXPORT_SYMBOL_GPL(netdev_switch_port_stp_update);
>  
>  static DEFINE_MUTEX(netdev_switch_mutex);
>  static RAW_NOTIFIER_HEAD(netdev_switch_notif_chain);
> @@ -74,7 +74,7 @@ int register_netdev_switch_notifier(struct notifier_block *nb)
>  	mutex_unlock(&netdev_switch_mutex);
>  	return err;
>  }
> -EXPORT_SYMBOL(register_netdev_switch_notifier);
> +EXPORT_SYMBOL_GPL(register_netdev_switch_notifier);
>  
>  /**
>   *	unregister_netdev_switch_notifier - Unregister nofifier
> @@ -92,7 +92,7 @@ int unregister_netdev_switch_notifier(struct notifier_block *nb)
>  	mutex_unlock(&netdev_switch_mutex);
>  	return err;
>  }
> -EXPORT_SYMBOL(unregister_netdev_switch_notifier);
> +EXPORT_SYMBOL_GPL(unregister_netdev_switch_notifier);
>  
>  /**
>   *	call_netdev_switch_notifiers - Call nofifiers
> @@ -115,7 +115,7 @@ int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
>  	mutex_unlock(&netdev_switch_mutex);
>  	return err;
>  }
> -EXPORT_SYMBOL(call_netdev_switch_notifiers);
> +EXPORT_SYMBOL_GPL(call_netdev_switch_notifiers);
>  
>  /**
>   *	netdev_switch_port_bridge_setlink - Notify switch device port of bridge
> @@ -140,7 +140,7 @@ int netdev_switch_port_bridge_setlink(struct net_device *dev,
>  
>  	return ops->ndo_bridge_setlink(dev, nlh, flags);
>  }
> -EXPORT_SYMBOL(netdev_switch_port_bridge_setlink);
> +EXPORT_SYMBOL_GPL(netdev_switch_port_bridge_setlink);
>  
>  /**
>   *	netdev_switch_port_bridge_dellink - Notify switch device port of bridge
> @@ -165,7 +165,7 @@ int netdev_switch_port_bridge_dellink(struct net_device *dev,
>  
>  	return ops->ndo_bridge_dellink(dev, nlh, flags);
>  }
> -EXPORT_SYMBOL(netdev_switch_port_bridge_dellink);
> +EXPORT_SYMBOL_GPL(netdev_switch_port_bridge_dellink);
>  
>  /**
>   *	ndo_dflt_netdev_switch_port_bridge_setlink - default ndo bridge setlink
> @@ -195,7 +195,7 @@ int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
>  
>  	return ret;
>  }
> -EXPORT_SYMBOL(ndo_dflt_netdev_switch_port_bridge_setlink);
> +EXPORT_SYMBOL_GPL(ndo_dflt_netdev_switch_port_bridge_setlink);
>  
>  /**
>   *	ndo_dflt_netdev_switch_port_bridge_dellink - default ndo bridge dellink
> @@ -225,7 +225,7 @@ int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
>  
>  	return ret;
>  }
> -EXPORT_SYMBOL(ndo_dflt_netdev_switch_port_bridge_dellink);
> +EXPORT_SYMBOL_GPL(ndo_dflt_netdev_switch_port_bridge_dellink);
>  
>  static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
>  {
> @@ -331,7 +331,7 @@ int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
>  
>  	return err;
>  }
> -EXPORT_SYMBOL(netdev_switch_fib_ipv4_add);
> +EXPORT_SYMBOL_GPL(netdev_switch_fib_ipv4_add);
>  
>  /**
>   *	netdev_switch_fib_ipv4_del - Delete IPv4 route entry from switch
> @@ -369,7 +369,7 @@ int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
>  
>  	return err;
>  }
> -EXPORT_SYMBOL(netdev_switch_fib_ipv4_del);
> +EXPORT_SYMBOL_GPL(netdev_switch_fib_ipv4_del);
>  
>  /**
>   *	netdev_switch_fib_ipv4_abort - Abort an IPv4 FIB operation
> @@ -389,4 +389,4 @@ void netdev_switch_fib_ipv4_abort(struct fib_info *fi)
>  	fib_flush_external(fi->fib_net);
>  	fi->fib_net->ipv4.fib_offload_disabled = true;
>  }
> -EXPORT_SYMBOL(netdev_switch_fib_ipv4_abort);
> +EXPORT_SYMBOL_GPL(netdev_switch_fib_ipv4_abort);
> 


-- 
Florian
