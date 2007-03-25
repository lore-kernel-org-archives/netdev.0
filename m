From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] [NET] Add IP(V6)_PMTUDISC_RPOBE
Date: Sat, 24 Mar 2007 21:23:27 -0700 (PDT)
Message-ID: <20070324.212327.75430968.davem@davemloft.net>
References: <11746948063923-git-send-email-jheffner@psc.edu>
	<11746948061847-git-send-email-jheffner@psc.edu>
	<11746948063971-git-send-email-jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59643
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S964988AbXCYEX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2007 00:23:28 -0400
In-Reply-To: <11746948063971-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Fri, 23 Mar 2007 20:06:46 -0400

> Add IP(V6)_PMTUDISC_PROBE value for IP(V6)_MTU_DISCOVER.  This option forces
> us not to fragment, but does not make use of the kernel path MTU discovery. 
> That is, it allows for user-mode MTU probing (or, packetization-layer path
> MTU discovery).  This is particularly useful for diagnostic utilities, like
> traceroute/tracepath.
> 
> Signed-off-by: John Heffner <jheffner@psc.edu>

Also applied to net-2.6.22, thanks John.

I made a slight change:

> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 4ff3940..64038b4 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -284,7 +284,8 @@ struct sk_buff {
>  				nfctinfo:3;
>  	__u8			pkt_type:3,
>  				fclone:2,
> -				ipvs_property:1;
> +				ipvs_property:1,
> +				ign_dst_mtu;
>  	__be16			protocol;
>  
>  	void			(*destructor)(struct sk_buff *skb);

I marked "ign_dst_mtu" with a bit field size of one since this
appears to be a boolean I take it this is what you mean to do
here.  Otherwise it adds another __u8 to struct sk_buff. :-)

