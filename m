From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [VLAN] vlan_dev: Initialize dev pointer only when it
 is being used
Date: Thu, 31 Jan 2008 15:06:55 +0100
Message-ID: <47A1D5FF.2020609@trash.net>
References: <1201762524-28403-1-git-send-email-ben@wenli.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Benjamin Li <ben@wenli.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49641 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764613AbYAaOHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 09:07:00 -0500
In-Reply-To: <1201762524-28403-1-git-send-email-ben@wenli.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Li wrote:
> Signed-off-by: Benjamin Li <ben@wenli.org>
> ---
>  net/8021q/vlan_dev.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index 8059fa4..2fa5d68 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -49,7 +49,7 @@
>   */
>  static int vlan_dev_rebuild_header(struct sk_buff *skb)
>  {
> -	struct net_device *dev = skb->dev;
> +	struct net_device *dev;
>  	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
>  
>  	switch (veth->h_vlan_encapsulated_proto) {
> @@ -60,6 +60,7 @@ static int vlan_dev_rebuild_header(struct sk_buff *skb)
>  		return arp_find(veth->h_dest, skb);
>  #endif
>  	default:
> +		dev = skb->dev;
>  		pr_debug("%s: unable to resolve type %X addresses.\n",
>  			 dev->name, ntohs(veth->h_vlan_encapsulated_proto));


This seems pretty pointless to me.
