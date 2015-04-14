From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4vf: Implement mailbox access locking and list
 management
Date: Tue, 14 Apr 2015 14:40:52 -0400 (EDT)
Message-ID: <20150414.144052.843726517109270692.davem@davemloft.net>
References: <1429014645-20361-1-git-send-email-hariprasad@chelsio.com>
	<20150414.142916.969366711752555436.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202AbbDNSky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 14:40:54 -0400
In-Reply-To: <20150414.142916.969366711752555436.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 14 Apr 2015 14:29:16 -0400 (EDT)

> From: Hariprasad Shenai <hariprasad@chelsio.com>
> Date: Tue, 14 Apr 2015 18:00:45 +0530
> 
>> +	for (i = 0; ; i += ms) {
>> +		/* If we've waited too long, return a busy indication.  This
>> +		 * really ought to be based on our initial position in the
>> +		 * mailbox access list but this is a start.  We very rarely
>> +		 * contend on access to the mailbox ...
>> +		 */
>> +		if (i > 4 * FW_CMD_MAX_TIMEOUT) {
> 
> So you're going to sit here potentially polling for 40000 ms in a non-preemptable
> context?
> 
> I don't think so...

Also, you haven't really explained in the commit message what the real
problem is and why the ordering of processing these messages matters
so much and furthermore what might go wrong if things are processed
out of order.

You have to assume I'm a complete idiot when I read your patches and
it is your job to explain to someone with now knowledge of your driver
or your hardware what you are doing.
