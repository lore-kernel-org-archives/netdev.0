From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] geneve: add rtnl changelink support
Date: Tue, 16 May 2017 15:31:15 -0400 (EDT)
Message-ID: <20170516.153115.2084299272043901950.davem@davemloft.net>
References: <1494870424-22699-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org, joe@ovn.org,
        jbenc@redhat.com
To: girish.moodalbail@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52782 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdEPTbR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 15:31:17 -0400
In-Reply-To: <1494870424-22699-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish Moodalbail <girish.moodalbail@oracle.com>
Date: Mon, 15 May 2017 10:47:04 -0700

>  	if (data[IFLA_GENEVE_REMOTE]) {
> -		info.key.u.ipv4.dst =
> +		info->key.u.ipv4.dst =
>  			nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
>  
> -		if (IN_MULTICAST(ntohl(info.key.u.ipv4.dst))) {
> +		if (IN_MULTICAST(ntohl(info->key.u.ipv4.dst))) {
>  			netdev_dbg(dev, "multicast remote is unsupported\n");
>  			return -EINVAL;
>  		}
> +		if (changelink &&
> +		    ip_tunnel_info_af(&geneve->info) == AF_INET6) {
> +			info->mode &= ~IP_TUNNEL_INFO_IPV6;
> +			info->key.tun_flags &= ~TUNNEL_CSUM;
> +			*use_udp6_rx_checksums = false;
> +		}
>  	}

I don't understand this "changelink" guarded code, why do you need to
clear all of this state out if the existing tunnel type if AF_INET6
and only when doing a changelink?

In any event, I think you need to add a comment explaining it.
