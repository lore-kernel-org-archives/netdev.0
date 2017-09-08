From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: fix regression of no RTM_DELADDR sent after
 DAD failure
Date: Thu, 07 Sep 2017 19:18:43 -0700 (PDT)
Message-ID: <20170907.191843.836588795188250550.davem@davemloft.net>
References: <1504536775-23533-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com
To: mmanning@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40782 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752093AbdIHCSo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 22:18:44 -0400
In-Reply-To: <1504536775-23533-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Manning <mmanning@brocade.com>
Date: Mon,  4 Sep 2017 15:52:55 +0100

> Commit f784ad3d79e5 ("ipv6: do not send RTM_DELADDR for tentative
> addresses") incorrectly assumes that no RTM_NEWADDR are sent for
> addresses in tentative state, as this does happen for the standard
> IPv6 use-case of DAD failure, see the call to ipv6_ifa_notify() in
> addconf_dad_stop(). So as a result of this change, no RTM_DELADDR is
> sent after DAD failure for a link-local when strict DAD (accept_dad=2)
> is configured, or on the next admin down in other cases. The absence
> of this notification breaks backwards compatibility and causes problems
> after DAD failure if this notification was being relied on. The
> solution is to allow RTM_DELADDR to still be sent after DAD failure.
> 
> Fixes: f784ad3d79e5("ipv6: do not send RTM_DELADDR for tentative addresses")
> Signed-off-by: Mike Manning <mmanning@brocade.com>
> Cc: Mahesh Bandewar <maheshb@google.com>

Mahesh, please review this patch.
