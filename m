From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip_tunnel: don't add tunnel twice
Date: Thu, 15 May 2014 23:10:51 -0400 (EDT)
Message-ID: <20140515.231051.1178432224326720292.davem@davemloft.net>
References: <53744B76.3080101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38867 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689AbaEPDKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 23:10:53 -0400
In-Reply-To: <53744B76.3080101@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Thu, 15 May 2014 13:07:02 +0800

> 
> When using command "ip tunnel add" to add a tunnel, the tunnel will be added twice,
> through ip_tunnel_create() and ip_tunnel_update().
> 
> Because the second is unnecessary, so we can just break after adding tunnel
> through ip_tunnel_create().
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

ip_tunnel_update() seems to do some things tha ip_tunnel_create()
does not.

For example, setting dev->dev_addr[] and dev->broadcast[] from the
ipv4 parms if appropriate.

I think you need to rethink this change.
