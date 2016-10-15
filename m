From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool: Zero memory allocated for statistics
Date: Fri, 14 Oct 2016 21:21:28 -0400 (EDT)
Message-ID: <20161014.212128.1303887902157786593.davem@davemloft.net>
References: <1476439158-66060-1-git-send-email-vlad@tsyrklevich.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vlad@tsyrklevich.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55188 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbcJOBW0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 21:22:26 -0400
In-Reply-To: <1476439158-66060-1-git-send-email-vlad@tsyrklevich.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Tsyrklevich <vlad@tsyrklevich.net>
Date: Fri, 14 Oct 2016 11:59:18 +0200

> enic_get_ethtool_stats()

Looknig merely at this shows the real problem.

We don't propagate and handle errors for this method.

And that's what we should fix, making the get_ethtool_stats() method
return an integer error.

Then ethtool_get_stats() should return any non-zero value provided by
ops->get_ethtool_stats() and not attempt to copy any bytes of 'data'
to userspace in that case.
