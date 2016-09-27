From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Tue, 27 Sep 2016 09:44:41 -0400 (EDT)
Message-ID: <20160927.094441.1957543068015677016.davem@davemloft.net>
References: <20160927.015606.437705429903770747.davem@davemloft.net>
        <20160927110711.12555f4e@pixies>
        <57EA4C66.8070907@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shmulik.ladkani@ravellosystems.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, edumazet@google.com,
        netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47480 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754759AbcI0Noq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 09:44:46 -0400
In-Reply-To: <57EA4C66.8070907@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 27 Sep 2016 12:39:34 +0200

> Any reason why dev_forward_skb() is not preferred over direct
> netif_receive_skb() you're using? It would, for example, implicitly
> assure that pkt_type is always PACKET_HOST, etc.

dev_forward_skb() will pull the ethernet header.

And since a direct call to netif_receive_skb() will not, one of these
two choices won't work properly.
