From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] tcp: Fix sysctl_tcp_max_orphans when PAGE_SIZE != 4k
Date: Thu, 26 Aug 2010 10:38:34 +1000
Message-ID: <20100826003834.GA17882@kryten>
References: <20100825071626.GA13681@kryten>
 <20100825071701.GA14962@kryten>
 <1282758634.2487.576.camel@edumazet-laptop>
 <20100825.165759.27789477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, miltonm@bga.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:50057 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752789Ab0HZAjs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 20:39:48 -0400
Content-Disposition: inline
In-Reply-To: <20100825.165759.27789477.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Dave,

> Yeah, something like the following, Anton?

Thanks! I tested on a 512GB box. One thing:

# cat /proc/sys/net/ipv4/tcp_max_syn_backlog 
128

We probably want to use max():

> -	sysctl_max_syn_backlog = min(128, cnt / 256);
> +	sysctl_max_syn_backlog = max(128, cnt / 256);

With that change:

# cat /proc/sys/net/ipv4/tcp_max_orphans 
262144
# cat /proc/sys/net/ipv4/tcp_max_tw_buckets
262144
# cat /proc/sys/net/ipv4/tcp_max_syn_backlog 
2048


Tested-by: Anton Blanchard <anton@samba.org>

Anton
