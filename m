From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, allow segmentation for gre tunneled skbs
Date: Wed, 10 Aug 2016 17:35:11 -0700 (PDT)
Message-ID: <20160810.173511.968926810628735179.davem@davemloft.net>
References: <1470726261-16371-1-git-send-email-wenxu@ucloud.cn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	shmulik.ladkani@gmail.com, wenx05124561@163.com,
	hannes@stressinduktion.org
To: wenxu@ucloud.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42169 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbcHKAfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 20:35:12 -0400
In-Reply-To: <1470726261-16371-1-git-send-email-wenxu@ucloud.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: wenxu@ucloud.cn
Date: Tue,  9 Aug 2016 15:04:21 +0800

> From: wenxu <wenxu@ucloud.cn>
> 
> commit b8247f095edd ("net: ip_finish_output_gso: If skb_gso_network_seglen
> exceeds MTU, allow segmentation for local udp tunneled skbs")
> 
> Given:
>      - tap0 and ovs-gre
>      - ovs-gre stacked on eth0, eth0 having the small mtu
> 
> After encapsulation these skbs have skb_gso_network_seglen that exceed
> eth0's ip_skb_dst_mtu. So the finnal each segment would be larger than
> eth0 mtu. These packets maybe dropped.
> 
> It has the same problem if tap0 bridge with ipgre or gretap device. So
> the IPSKB_FRAG_SEGS flags should also be set in gre tunneled skbs.
> 
> Signed-off-by: wenxu <wenxu@ucloud.cn>

I am rather certain that this test is intentionally restricted to
UDP tunnel endpoints, because GRE and other tunnel types are PMTU safe.

Hannes and Shmulik?
