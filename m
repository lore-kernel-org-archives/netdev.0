From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 1/5] netdev: introduce ndo_set_rx_headroom
Date: Thu, 25 Feb 2016 17:21:32 +0300
Message-ID: <56CF0DEC.6030308@cogentembedded.com>
References: <cover.1456397229.git.pabeni@redhat.com>
 <94f5bf927e514df4fecd50a1332a56501fff2945.1456397229.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@kernel.org>,
	Flavio Leitner <fbl@sysclose.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:33117 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932337AbcBYOVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 09:21:34 -0500
Received: by mail-lb0-f179.google.com with SMTP id x4so29895921lbm.0
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 06:21:33 -0800 (PST)
In-Reply-To: <94f5bf927e514df4fecd50a1332a56501fff2945.1456397229.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/25/2016 2:09 PM, Paolo Abeni wrote:

> This method allows the controlling device (i.e. the bridge) to specify
> additional headroom to be allocated for skb head on frame reception.
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
>
> ---
> v1 -> v2:
>   - fixed netdev_get_fwd_headroom()
>   - added netdev_set_rx_headroom() and netdev_reset_rx_headroom() helpers
> ---
>   include/linux/netdevice.h | 31 +++++++++++++++++++++++++++++++
>   1 file changed, 31 insertions(+)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index e52077f..8f53674 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1093,6 +1093,12 @@ struct tc_to_netdev {
>    *	This function is used to get egress tunnel information for given skb.
>    *	This is useful for retrieving outer tunnel header parameters while
>    *	sampling packet.
> + * * int (*ndo_set_rx_headroom)(struct net_device *dev, int needed_headroom);

    It's *void* in the declaration.

> + *	This function is used to specify the headroom that the skb must
> + *	consider when allocation skb during packet reception. Setting
> + *	appropriate rx headroom value allows avoiding skb head copy on
> + *	forward. Setting a negative value reset the rx headroom to the
> + *	default value.
>    *
>    */
>   struct net_device_ops {
> @@ -1278,6 +1284,8 @@ struct net_device_ops {
>   							 bool proto_down);
>   	int			(*ndo_fill_metadata_dst)(struct net_device *dev,
>   						       struct sk_buff *skb);
> +	void			(*ndo_set_rx_headroom)(struct net_device *dev,
> +						       int needed_headroom);
>   };
>
>   /**
[...]

MBR, Sergei
