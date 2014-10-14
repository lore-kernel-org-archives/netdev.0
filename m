From: David Miller <davem@davemloft.net>
Subject: Re: [patch net repost] ipv4: fix nexthop attlen check in
 fib_nh_match
Date: Tue, 14 Oct 2014 15:33:42 -0400 (EDT)
Message-ID: <20141014.153342.970326469632179961.davem@davemloft.net>
References: <1413210850-14456-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, edumazet@google.com,
	tgraf@suug.ch
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755357AbaJNTdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 15:33:45 -0400
In-Reply-To: <1413210850-14456-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 13 Oct 2014 16:34:10 +0200

> fib_nh_match does not match nexthops correctly. Example:
> 
> ip route add 172.16.10/24 nexthop via 192.168.122.12 dev eth0 \
>                           nexthop via 192.168.122.13 dev eth0
> ip route del 172.16.10/24 nexthop via 192.168.122.14 dev eth0 \
>                           nexthop via 192.168.122.15 dev eth0
> 
> Del command is successful and route is removed. After this patch
> applied, the route is correctly matched and result is:
> RTNETLINK answers: No such process
> 
> Please consider this for stable trees as well.
> 
> Fixes: 4e902c57417c4 ("[IPv4]: FIB configuration using struct fib_config")
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Acked-by: Eric Dumazet <edumazet@google.com>
> ---
> reposted with example (it was missing for some reason in the original post)

Applied and queued up for -stable, thanks Jiri!
