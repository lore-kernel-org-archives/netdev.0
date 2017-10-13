From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] cxgb4: add support to get hardware debug
 logs via ethtool
Date: Thu, 12 Oct 2017 23:04:50 -0700 (PDT)
Message-ID: <20171012.230450.1204546400655929554.davem@davemloft.net>
References: <cover.1507795407.git.rahul.lakkireddy@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com
To: rahul.lakkireddy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35548 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750872AbdJMGEv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 02:04:51 -0400
In-Reply-To: <cover.1507795407.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Date: Thu, 12 Oct 2017 13:54:37 +0530

> This series of patches add support to collect hardware debug logs
> via ethtool --get-dump facility.

There is a lot of global namespace pollution added by these
changes.

A lot of the global symbols you add in this new code have very
poorly namespaced names like "collect_mem_info()"

If the driver is built statically into the kernel this will pollute
the global namespace and conflict with any symbols elsewhere in the
kernel that have the same name.

So please use a proper "cxgb4_" or similar prefix for any non-static
symbols in the driver.

Thank you.
