From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: extend net_device allocation to
 vmalloc()
Date: Sun, 03 Nov 2013 23:19:36 -0500 (EST)
Message-ID: <20131103.231936.1376432697924210356.davem@davemloft.net>
References: <1383141242.4857.36.camel@edumazet-glaptop.roam.corp.google.com>
	<1383145278.4857.46.camel@edumazet-glaptop.roam.corp.google.com>
	<1383163844.4857.59.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joby.poriyath@citrix.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, wei.liu2@citrix.com,
	ian.campbell@citrix.com, xen-devel@lists.xen.org,
	andrew.bennieston@citrix.com, david.vrabel@citrix.com,
	malcolm.crossley@citrix.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683Ab3KDETj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 23:19:39 -0500
In-Reply-To: <1383163844.4857.59.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Oct 2013 13:10:44 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Joby Poriyath provided a xen-netback patch to reduce the size of
> xenvif structure as some netdev allocation could fail under
> memory pressure/fragmentation.
> 
> This patch is handling the problem at the core level, allowing
> any netdev structures to use vmalloc() if kmalloc() failed.
> 
> As vmalloc() adds overhead on a critical network path, add __GFP_REPEAT
> to kzalloc() flags to do this fallback only when really needed.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Joby Poriyath <joby.poriyath@citrix.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> ---
> v2: change the Documentation to point to alloc_netdev_mqs()
>     instead of kmalloc()/vzalloc(), from Ben

Looks good, applied, thanks Eric.
