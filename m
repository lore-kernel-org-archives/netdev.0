From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3] rtnetlink: delay RTM_DELLINK notification
 until after ndo_uninit()
Date: Tue, 02 Dec 2014 23:39:17 -0800
Message-ID: <1417592357.5303.130.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417591497-24246-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:50837 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbaLCHjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 02:39:20 -0500
Received: by mail-ig0-f172.google.com with SMTP id hl2so16368557igb.11
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 23:39:19 -0800 (PST)
In-Reply-To: <1417591497-24246-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-02 at 23:24 -0800, Mahesh Bandewar wrote:

> +EXPORT_SYMBOL(rtmsg_ifinfo_build_skb);
> +
> +void rtmsg_ifinfo_send(struct sk_buff *skb, struct net_device *dev, gfp_t flags)
> +{
> +	struct net *net = dev_net(dev);
> +
> +	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, flags);
> +}
> +EXPORT_SYMBOL(rtmsg_ifinfo_send);
> +
> +void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
> +		  gfp_t flags)
> +{
> +	struct sk_buff *skb;
> +
> +	skb = rtmsg_ifinfo_build_skb(type, dev, change, flags);
> +	if (skb)
> +		rtmsg_ifinfo_send(skb, dev, flags);
>  }
>  EXPORT_SYMBOL(rtmsg_ifinfo);

One last point :

Only rtmsg_ifinfo() needs the EXPORT_SYMBOL(...)

rtmsg_ifinfo_build_skb() and rtmsg_ifinfo_send() are used from core networking stack,
not a module.
