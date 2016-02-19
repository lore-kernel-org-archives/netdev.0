From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: make netdev_for_each_lower_dev safe for
 device removal
Date: Fri, 19 Feb 2016 15:31:10 -0500 (EST)
Message-ID: <20160219.153110.795725800045343996.davem@davemloft.net>
References: <1455728431-21976-1-git-send-email-razor@blackwall.org>
	<56C4C376.2000400@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: razor@blackwall.org, netdev@vger.kernel.org,
	nikolay@cumulusnetworks.com, roopa@cumulusnetworks.com,
	vyasevic@redhat.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422953AbcBSUbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 15:31:12 -0500
In-Reply-To: <56C4C376.2000400@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 17 Feb 2016 12:01:10 -0700

> On 2/17/16 10:00 AM, Nikolay Aleksandrov wrote:
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>
>> When I used netdev_for_each_lower_dev in commit bad531623253 ("vrf:
>> remove slave queue and private slave struct") I thought that it acts
>> like netdev_for_each_lower_private and can be used to remove the
>> current
>> device from the list while walking, but unfortunately it acts more
>> like
>> netdev_for_each_lower_private_rcu and doesn't allow it. The difference
>> is where the "iter" points to, right now it points to the current
>> element
>> and that makes it impossible to remove it. Change the logic to be
>> similar to netdev_for_each_lower_private and make it point to the
>> "next"
>> element so we can safely delete the current one. VRF is the only such
>> user right now, there's no change for the read-only users.
 ...
>> Fixes: bad531623253 ("vrf: remove slave queue and private slave
>> struct")
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> ---
>>   include/linux/netdevice.h | 2 +-
>>   net/core/dev.c            | 4 ++--
>>   2 files changed, 3 insertions(+), 3 deletions(-)
> 
> Solves the problem for me. Thanks for the quick turnaround, Nik.
> 
> Reviewed-by / Tested-by: David Ahern <dsa@cumulusnetworks.com>

David, please explicitly list these tags one by one, patchwork is not
able to pick them up if you try to free-form the tags.  I had to
incorporate them by hand, but that makes more work for me.

Applied, thanks.
