From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/5] be2net: pass domain id to
 be_cmd_link_status_query
Date: Mon, 18 Apr 2011 22:56:59 -0700 (PDT)
Message-ID: <20110418.225659.112612060.davem@davemloft.net>
References: <20110418223033.GA9515@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajit.khaparde@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43188
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751650Ab1DSF5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 01:57:34 -0400
In-Reply-To: <20110418223033.GA9515@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@emulex.com>
Date: Mon, 18 Apr 2011 17:30:33 -0500

> 
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>

That's not all this patch does:

> @@ -293,7 +293,6 @@ struct be_adapter {
>  	u8 eq_next_idx;
>  	struct be_drv_stats drv_stats;
>  
> -	struct vlan_group *vlan_grp;
>  	u16 vlans_added;
>  	u16 max_vlans;	/* Number of vlans supported */
>  	u8 vlan_tag[VLAN_N_VID];
...
> @@ -1012,15 +1004,10 @@ static void be_rx_compl_process(struct be_adapter *adapter,
>  		skb->rxhash = rxcp->rss_hash;
>  
>  
> -	if (unlikely(rxcp->vlanf)) {
> -		if (!adapter->vlan_grp || adapter->vlans_added == 0) {
> -			kfree_skb(skb);
> -			return;
> -		}
> -		vlan_hwaccel_receive_skb(skb, adapter->vlan_grp, rxcp->vid);
> -	} else {
> -		netif_receive_skb(skb);
> -	}
> +	if (unlikely(rxcp->vlanf))
> +		__vlan_hwaccel_put_tag(skb, rxcp->vid);
> +
> +	netif_receive_skb(skb);
>  }
>  
>  /* Process the RX completion indicated by rxcp when GRO is enabled */

It seems to be also converting the driver over to the new VLAN
interfaces.

Please seperate this part into a seperate patch and resubmit your
patch series.

Thanks.
