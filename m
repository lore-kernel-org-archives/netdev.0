From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [patch net-next] bonding: create netlink event when bonding
 option is changed
Date: Wed, 20 Aug 2014 08:18:28 -0400
Message-ID: <20140820121828.GA31336@hmsreliant.think-freely.org>
References: <1408456932-10318-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, j.vosburgh@gmail.com,
	vfalico@gmail.com, andy@greyhouse.net, nikolay@redhat.com,
	dingtianhong@huawei.com, sfeldma@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47870 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752229AbaHTMSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 08:18:44 -0400
Content-Disposition: inline
In-Reply-To: <1408456932-10318-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2014 at 04:02:12PM +0200, Jiri Pirko wrote:
> Userspace needs to be notified if one changes some option.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  drivers/net/bonding/bond_options.c | 2 ++
>  include/linux/netdevice.h          | 1 +
>  2 files changed, 3 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
> index dc73463..d8dc17f 100644
> --- a/drivers/net/bonding/bond_options.c
> +++ b/drivers/net/bonding/bond_options.c
> @@ -625,6 +625,8 @@ int __bond_opt_set(struct bonding *bond,
>  out:
>  	if (ret)
>  		bond_opt_error_interpret(bond, opt, ret, val);
> +	else
> +		call_netdevice_notifiers(NETDEV_CHANGEINFODATA, bond->dev);
>  
>  	return ret;
>  }
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 967ddcc..44bc4bd 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2017,6 +2017,7 @@ struct pcpu_sw_netstats {
>  #define NETDEV_CHANGEUPPER	0x0015
>  #define NETDEV_RESEND_IGMP	0x0016
>  #define NETDEV_PRECHANGEMTU	0x0017 /* notify before mtu change happened */
> +#define NETDEV_CHANGEINFODATA	0x0018
>  
Do you need to create a new netdev event here?  Seems like it might be more
concise to reuse NETDEV_CHANGE and expand the netdev_notifier_change_info
struct.

Neil

>  int register_netdevice_notifier(struct notifier_block *nb);
>  int unregister_netdevice_notifier(struct notifier_block *nb);
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
