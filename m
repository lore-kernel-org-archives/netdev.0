From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] via-rhine: add 64bit statistics.
Date: Wed, 23 Jan 2013 16:27:42 -0800
Message-ID: <1358987262.12374.1283.camel@edumazet-glaptop>
References: <50fff42d.094e640a.3ace.6ae4@mx.google.com>
	 <1358951884.12374.790.camel@edumazet-glaptop>
	 <510004a3.2444ec0a.1ba7.ffff98b3@mx.google.com>
	 <1358957838.12374.805.camel@edumazet-glaptop>
	 <5100786f.04bc650a.65b3.fffffd3d@mx.google.com>
	 <1358985772.12374.1250.camel@edumazet-glaptop>
	 <51007e6c.4170ec0a.7218.18c2@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jamie Gloudon <jamie.gloudon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:44433 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346Ab3AXA1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 19:27:48 -0500
Received: by mail-pb0-f47.google.com with SMTP id wz17so5025097pbc.34
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 16:27:48 -0800 (PST)
In-Reply-To: <51007e6c.4170ec0a.7218.18c2@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 20:20 -0400, Jamie Gloudon wrote:

> Right. Also, I added rx_dropped to increment for oversize ethernet. Is
> that valid?
> 
> @@ -1857,6 +1869,7 @@ static int rhine_rx(struct net_device *dev, int
> limit)
> 	"Oversized Ethernet frame %p vs %p\n", rp->rx_head_desc,                        	&rp->rx_ring[entry]);
> +	dev->stats.rx_dropped++;
> 	dev->stats.rx_length_errors++;

Take other drivers as reference

git grep -n2 rx_length_errors -- drivers/net

Most of them dont do that (they are more likely increasing rx_errors)
