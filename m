From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: improve sanity check for received domain
 records
Date: Fri, 25 Nov 2016 20:07:05 -0500 (EST)
Message-ID: <20161125.200705.753838440776712819.davem@davemloft.net>
References: <1479962769-24239-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parthasarathy.bhuvaragan@ericsson.com,
        ying.xue@windriver.com, maloy@donjonn.com,
        tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57870 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751968AbcKZBHI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 20:07:08 -0500
In-Reply-To: <1479962769-24239-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 23 Nov 2016 23:46:09 -0500

> In commit 35c55c9877f8 ("tipc: add neighbor monitoring framework") we
> added a data area to the link monitor STATE messages under the
> assumption that previous versions did not use any such data area.
> 
> For versions older than Linux 4.3 this assumption is not correct. In
> those version, all STATE messages sent out from a node inadvertently
> contain a 16 byte data area containing a string; -a leftover from
> previous RESET messages which were using this during the setup phase.
> This string serves no purpose in STATE messages, and should no be there.
> 
> Unfortunately, this data area is delivered to the link monitor
> framework, where a sanity check catches that it is not a correct domain
> record, and drops it. It also issues a rate limited warning about the
> event.
> 
> Since such events occur much more frequently than anticipated, we now
> choose to remove the warning in order to not fill the kernel log with
> useless contents. We also make the sanity check stricter, to further
> reduce the risk that such data is inavertently admitted.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
