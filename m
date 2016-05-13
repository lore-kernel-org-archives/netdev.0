From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3] udp: Resolve NULL pointer dereference over
 flow-based vxlan device
Date: Fri, 13 May 2016 01:56:55 -0400 (EDT)
Message-ID: <20160513.015655.970103770930303286.davem@davemloft.net>
References: <20160512022306.3691.40769.stgit@localhost.localdomain>
	<20160512232203.12606.41050.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com, tgraf@suug.ch,
	tom@herbertland.com, jbenc@redhat.com, eric.dumazet@gmail.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbcEMF46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 01:56:58 -0400
In-Reply-To: <20160512232203.12606.41050.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Thu, 12 May 2016 16:23:44 -0700

> While testing an OpenStack configuration using VXLANs I saw the following
> call trace:
 ...
> The following trace is seen when receiving a DHCP request over a flow-based
> VXLAN tunnel.  I believe this is caused by the metadata dst having a NULL
> dev value and as a result dev_net(dev) is causing a NULL pointer dereference.
> 
> To resolve this I am replacing the check for skb_dst(skb)->dev with just
> skb->dev.  This makes sense as the callers of this function are usually in
> the receive path and as such skb->dev should always be populated.  In
> addition other functions in the area where these are called are already
> using dev_net(skb->dev) to determine the namespace the UDP packet belongs
> in.
> 
> Fixes: 63058308cd55 ("udp: Add udp6_lib_lookup_skb and udp4_lib_lookup_skb")
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Applied, thanks!
