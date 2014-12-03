From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] rtnetlink: delay RTM_DELLINK notification
 until after ndo_uninit()
Date: Tue, 02 Dec 2014 19:02:15 -0800
Message-ID: <1417575735.5303.84.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417574617-27560-1-git-send-email-maheshb@google.com>
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
Received: from mail-ie0-f176.google.com ([209.85.223.176]:43649 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbaLCDCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 22:02:17 -0500
Received: by mail-ie0-f176.google.com with SMTP id tr6so12476388ieb.7
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 19:02:17 -0800 (PST)
In-Reply-To: <1417574617-27560-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-02 at 18:43 -0800, Mahesh Bandewar wrote:

> +
> +void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
> +		  gfp_t flags)
> +{
> +	struct sk_buff *skb;
> +
> +	skb = rtmsg_ifinfo_build_skb(type, dev, change, flags);
> +	if (!skb)

	if (skb)

> +		rtmsg_ifinfo_send(skb, dev, flags);
>  }
>  EXPORT_SYMBOL(rtmsg_ifinfo);
>  
