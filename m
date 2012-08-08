From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: force dst_default_metrics to const section
Date: Wed, 08 Aug 2012 16:00:51 -0700 (PDT)
Message-ID: <20120808.160051.2296746021327619852.davem@davemloft.net>
References: <1344355878.28967.113.camel@edumazet-glaptop>
	<1344370527.2688.61.camel@bwh-desktop.uk.solarflarecom.com>
	<1344372945.28967.165.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757918Ab2HHXAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 19:00:52 -0400
In-Reply-To: <1344372945.28967.165.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Aug 2012 22:55:45 +0200

> [PATCH v2] net: force dst_default_metrics to const section
> 
> While investigating on network performance problems, I found this little
> gem :
> 
> $ nm -v vmlinux | grep -1 dst_default_metrics
> ffffffff82736540 b busy.46605 
> ffffffff82736560 B dst_default_metrics
> ffffffff82736598 b dst_busy_list
> 
> Apparently, declaring a const array without initializer put it in
> (writeable) bss section, in middle of possibly often dirtied cache
> lines.
> 
> Since we really want dst_default_metrics be const to avoid any possible
> false sharing and catch any buggy writes, I force a null initializer.
> 
> ffffffff818a4c20 R dst_default_metrics
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks.
