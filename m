From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipmr, ip6mr: fix scheduling while atomic and a
 deadlock with ipmr_get_route
Date: Sun, 25 Sep 2016 23:42:38 -0400 (EDT)
Message-ID: <20160925.234238.501504782961869524.davem@davemloft.net>
References: <1474837711-19277-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, roopa@cumulusnetworks.com,
        sharpd@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55158 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932234AbcIZDmn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 23:42:43 -0400
In-Reply-To: <1474837711-19277-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Sun, 25 Sep 2016 23:08:31 +0200

> Since the commit below the ipmr/ip6mr rtnl_unicast() code uses the portid
> instead of the previous dst_pid which was copied from in_skb's portid.
> Since the skb is new the portid is 0 at that point so the packets are sent
> to the kernel and we get scheduling while atomic or a deadlock (depending
> on where it happens) by trying to acquire rtnl two times.
> Also since this is RTM_GETROUTE, it can be triggered by a normal user.
> 
> Here's the sleeping while atomic trace:
 ...
> Fixes: 2942e9005056 ("[RTNETLINK]: Use rtnl_unicast() for rtnetlink unicasts")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This approach looks fine to me, applied and queued up for -stable.
