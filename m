From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net: add real socket cookies
Date: Wed, 11 Mar 2015 21:55:53 -0400 (EDT)
Message-ID: <20150311.215553.1544350193194225837.davem@davemloft.net>
References: <1426113035.11398.90.camel@edumazet-glaptop2.roam.corp.google.com>
	<1426114608.11398.94.camel@edumazet-glaptop2.roam.corp.google.com>
	<1426125194.11398.131.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, salo@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551AbbCLBzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 21:55:54 -0400
In-Reply-To: <1426125194.11398.131.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Mar 2015 18:53:14 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> A long standing problem in netlink socket dumps is the use
> of kernel socket addresses as cookies.
> 
> 1) It is a security concern.
> 
> 2) Sockets can be reused quite quickly, so there is
>    no guarantee a cookie is used once and identify
>    a flow.
> 
> 3) request sock, establish sock, and timewait socks
>    for a given flow have different cookies.
> 
> 
> Part of our effort to bring better TCP statistics requires
> to switch to a different allocator.
> 
> In this patch, I chose to use a per network namespace 64bit generator,
> and to use it only in the case a socket needs to be dumped to netlink.
> (This might be refined later if needed)
> 
> Note that I tried to carry cookies from request sock, to establish sock,
> then timewait sockets.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Eric Salo <salo@google.com>
> ---
> v3:  use atomic64_set() in inet_csk_clone_lock() as David requested.

Oh, even better, I'll push this one actually.

Thanks!
