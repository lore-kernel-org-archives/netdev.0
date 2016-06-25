From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4vf: Synchronize access to mailbox
Date: Sat, 25 Jun 2016 12:04:52 -0400 (EDT)
Message-ID: <20160625.120452.1848645610639208563.davem@davemloft.net>
References: <1466568569-19120-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54457 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbcFYQEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 12:04:55 -0400
In-Reply-To: <1466568569-19120-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 22 Jun 2016 09:39:29 +0530

> The issue comes when there are multiple threads attempting to use the
> mailbox facility at the same time. The issue is the for the Virtual
> Function Driver, the only way to get the Virtual Interface statistics
> is to issue mailbox commands to ask the firmware for the VI Stats.
> And, because the VI Stats command can only retrieve a smallish number of
> stats per mailbox command, we have to issue three mailbox commands in quick
> succession. When ethtool or netstat command to get interface stats and
> interface up/down is run in a loop for every 0.1 sec, we observed
> mailbox collisions. And out of the two commands one would fail with
> the present code, since we don't queue the second command.
> 
> To overcome the above issue, added a queue to access the mailbox.
> Whenever a mailbox command is issued add it to the queue. If its at the
> head issue the mailbox command, else wait for the existing command to
> complete. Usually command takes less than a milli-second to complete.
> Also timeout from the loop, if the command under execution takes
> long time to run.
> 
> In reality, the number of mailbox access collisions is going to be very
> rare since no one runs such abusive script.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
