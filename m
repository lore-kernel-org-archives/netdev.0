From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFC 4/5] bridge: let HW control FDB ageing by
 setting NTF_EXT_AGED
Date: Fri, 20 Feb 2015 12:31:55 -0500 (EST)
Message-ID: <20150220.123155.1339488736970212441.davem@davemloft.net>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
	<1424416195-19098-5-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, gospo@cumulusnetworks.com,
	vbandaru@broadcom.com, siva.mannem.lnx@gmail.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755122AbbBTRcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 12:32:01 -0500
In-Reply-To: <1424416195-19098-5-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Thu, 19 Feb 2015 23:09:54 -0800

> @@ -990,10 +993,13 @@ void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p)
>  }
>  
>  int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
> -			      const unsigned char *addr, u16 vid)
> +			      struct netdev_switch_notifier_fdb_info *fdb_info)
>  {
 ...
> @@ -1026,10 +1034,12 @@ err_unlock:
>  }
>  
>  int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
> -			      const unsigned char *addr, u16 vid)
> +			      struct netdev_switch_notifier_fdb_info *fdb_info)
>  {
 ...
> @@ -403,9 +405,9 @@ int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
>  int br_fdb_sync_static(struct net_bridge *br, struct net_bridge_port *p);
>  void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p);
>  int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
> -			      const unsigned char *addr, u16 vid);
> +			      struct netdev_switch_notifier_fdb_info *fdb_info);
>  int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
> -			      const unsigned char *addr, u16 vid);
> +			      struct netdev_switch_notifier_fdb_info *fdb_info);

You probably want to mark the fdb_info argument as 'const'.
