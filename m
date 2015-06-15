From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 1/4] net: don't reforward packets already
 forwarded by offload device
Date: Mon, 15 Jun 2015 07:21:21 -0700
Message-ID: <557EDF61.8010709@cumulusnetworks.com>
References: <1434218670-43821-1-git-send-email-sfeldma@gmail.com> <1434218670-43821-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	simon.horman@netronome.com, ronen.arad@intel.com,
	john.r.fastabend@intel.com, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, davidch@broadcom.com,
	stephen@networkplumber.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:33980 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932156AbbFOOVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 10:21:23 -0400
Received: by pdbki1 with SMTP id ki1so74090816pdb.1
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 07:21:22 -0700 (PDT)
In-Reply-To: <1434218670-43821-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/13/15, 11:04 AM, sfeldma@gmail.com wrote:
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 6f5f71f..181b08f 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1444,6 +1444,8 @@ enum netdev_priv_flags {
>    *
>    *	@xps_maps:	XXX: need comments on this one
>    *
> + *	@fwd_mark:		Offload device fwding mark
> + *
>    *	@trans_start:		Time (in jiffies) of last Tx
>    *	@watchdog_timeo:	Represents the timeout that is used by
>    *				the watchdog ( see dev_watchdog() )
> @@ -1681,6 +1683,10 @@ struct net_device {
>   	struct xps_dev_maps __rcu *xps_maps;
>   #endif
>   
> +#ifdef CONFIG_NET_SWITCHDEV
> +	u32			fwd_mark;
> +#endif
> +
>   
scott, Just calling out a few other use-cases to make sure this flag can 
be used in a generic way in the future:
- avoid updating acl counters in the kernel when hardware acl counters 
have already accounted for this packet
- ability to conditionally clear the mark  by other protocols  in the 
kernel before xmit: one use case is the bridge driver allowing software 
forwarding of some protocol packets when hardware forwarding of these is 
turned off eg igmp (As I understand, This is possible with your patch 
series if we need to in the future)

PS: Maybe the name should be generic enough to suite other use-cases in 
the future (i like the name i had hw_offloaded better ;).
