From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: add adaptive coalescing
Date: Tue, 06 Oct 2009 17:25:37 -0700 (PDT)
Message-ID: <20091006.172537.148962576.davem@davemloft.net>
References: <4ACB75DB.4060003@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44862
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933504AbZJGAZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 20:25:42 -0400
In-Reply-To: <4ACB75DB.4060003@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Tue, 06 Oct 2009 18:52:43 +0200

> This patch adds support for adaptive interrupt coalescing to the
> myri10ge driver. It is based on the host periodically look at
> statistics and update the NIC coalescing accordingly.
> 
> The NIC only provides packet throughput and we feel that it is a
> better heuristics than the packet rate heuristics currently used
> in ethtool. Also, assuming that the packet packet rate heuristics
> uses what is actually sent on the wire when using TSO, it would be
> much more expensive to implement correctly, as the driver would
> need to calculate how many packets were sent.
> 
> Signed-off-by: Andrew Gallatin <gallatin@myri.com>
> Signed-off-by: Brice Goglin <brice@myri.com>

Drivers tried to do this as far back as 6 years ago (tg3) and we don't
recommend doing this with NAPI drivers.

You detection code can never respond quick enough in response to
changes in traffic conditions.  By the time you program the new values
into the registers things on the wire can change a lot.

It's also very easy to flap and hit the settings a lot.

That's why we recommend using low hw mitigation settings and simply
leaving it like that.
