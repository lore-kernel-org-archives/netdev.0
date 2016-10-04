From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 4/4] net/sched: act_mirred: Implement
 ingress actions
Date: Mon, 03 Oct 2016 21:45:36 -0400 (EDT)
Message-ID: <20161003.214536.1564485172411156614.davem@davemloft.net>
References: <1475147012-15538-1-git-send-email-shmulik.ladkani@gmail.com>
        <1475147012-15538-5-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, edumazet@google.com,
        daniel@iogearbox.net, netdev@vger.kernel.org,
        eric.dumazet@gmail.com
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52718 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbcJDBpk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 21:45:40 -0400
In-Reply-To: <1475147012-15538-5-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Thu, 29 Sep 2016 14:03:32 +0300

>  	skb2->skb_iif = skb->dev->ifindex;
>  	skb2->dev = dev;
> -	err = dev_queue_xmit(skb2);
> +	if (tcf_mirred_act_direction(m_eaction) & AT_EGRESS)
> +		err = dev_queue_xmit(skb2);
> +	else
> +		netif_receive_skb(skb2);

Can you address the feedback about lack of checking the return
value of netif_receive_skb()?  It seems like a legitimate issue,
thanks.
