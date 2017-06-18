From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 10/13] net: ena: add mtu limitation in
 ena_change_mtu()
Date: Sun, 18 Jun 2017 12:21:03 -0400 (EDT)
Message-ID: <20170618.122103.1131376179675660541.davem@davemloft.net>
References: <1497785298-13468-1-git-send-email-netanel@amazon.com>
        <1497785298-13468-11-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dwmw@amazon.com, zorik@amazon.com,
        matua@amazon.com, saeedb@amazon.com, msw@amazon.com,
        aliguori@amazon.com, nafea@amazon.com, evgenys@amazon.com
To: netanel@amazon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752950AbdFRQVH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 12:21:07 -0400
In-Reply-To: <1497785298-13468-11-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <netanel@amazon.com>
Date: Sun, 18 Jun 2017 14:28:15 +0300

> From: Netanel Belgazal <netanel@amazon.com>
> 
> Signed-off-by: Netanel Belgazal <netanel@amazon.com>

I don't understand this at all.

This whole reason we have those:

> @@ -3008,8 +3015,6 @@ static void ena_set_conf_feat_params(struct ena_adapter *adapter,
>  	ena_set_dev_offloads(feat, netdev);
>  
>  	adapter->max_mtu = feat->dev_attr.max_mtu;
> -	netdev->max_mtu = adapter->max_mtu;
> -	netdev->min_mtu = ENA_MIN_MTU;
>  }
>  

assignments you are removing is so that the core networking can
validate the request and therefore individual drivers don't have to.

If it's just to get that silly driver message out when the MTU asked
for is too large, that's not a good reason to bypass the
infrastructure for MTU changes that we've provided for drivers in the
core.

I don't like this change at all.

You could have helped things a lot by actually writing a commit log
message explaining what you are really doing, and why you are doing
it.  Empty commit log messages are never a good idea.
