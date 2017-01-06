From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] cxgb4: Synchronize access to mailbox
Date: Fri, 06 Jan 2017 15:55:46 -0500 (EST)
Message-ID: <20170106.155546.287211400588300555.davem@davemloft.net>
References: <1483672640-18185-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
        ganeshgr@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41058 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938948AbdAFUzs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:55:48 -0500
In-Reply-To: <1483672640-18185-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri,  6 Jan 2017 08:47:20 +0530

> The issue comes when there are multiple threads attempting to use
> the mailbox facility at the same time.
> When DCB operations and interface up/down is run in a loop for every
> 0.1 sec, we observed mailbox collisions. And out of the two commands
> one would fail with the present code, since we don't queue the second
> command.
> 
> To overcome the above issue, added a queue to access the mailbox.
> Whenever a mailbox command is issued add it to the queue. If its at
> the head issue the mailbox command, else wait for the existing command
> to complete. Usually command takes less than a milli-second to
> complete.
> 
> Also timeout from the loop, if the command under execution takes
> long time to run.
> 
> In reality, the number of mailbox access collisions is going to be
> very rare since no one runs such abusive script.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
