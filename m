From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv4: remove disable of bottom half in
 inet_rtm_getroute
Date: Mon, 09 Jan 2017 13:55:37 -0500 (EST)
Message-ID: <20170109.135537.139485824392742134.davem@davemloft.net>
References: <1483848263-17031-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47040 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163358AbdAISzi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 13:55:38 -0500
In-Reply-To: <1483848263-17031-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sat,  7 Jan 2017 20:04:23 -0800

> Nothing about the route lookup requires bottom half to be disabled.
> Remove the local_bh_disable ... local_bh_enable around ip_route_input.
> This appears to be a vestige of days gone by as it has been there
> since the beginning of git time.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Agreed, this shouldn't be necessary.

The key with input route lookups is that the skb->dst reference cannot
escape the packet receive path, unless we force the dst, which
ip_route_input() does under RCU protection.

So this should all be ok.

Applied, thanks.
