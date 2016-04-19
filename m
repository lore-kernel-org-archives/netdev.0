From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Mon, 18 Apr 2016 23:49:55 -0400 (EDT)
Message-ID: <20160418.234955.787362423469281895.davem@davemloft.net>
References: <20160418.214851.122286645854721047.davem@davemloft.net>
	<1461032539.10638.143.camel@edumazet-glaptop3.roam.corp.google.com>
	<57159A88.3030401@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, jhs@mojatatu.com,
	tgraf@suug.ch, nicolas.dichtel@6wind.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbcDSDuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 23:50:00 -0400
In-Reply-To: <57159A88.3030401@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Mon, 18 Apr 2016 19:40:08 -0700

> On 4/18/16, 7:22 PM, Eric Dumazet wrote:
>> On Mon, 2016-04-18 at 21:48 -0400, David Miller wrote:
>>
>>> And anyways, I get unaligned accesses without Roopa's changes :-/
>>>
>>> davem@patience:~$ ip l l
>>> [3391066.656729] Kernel unaligned access at TPC[7d6c14] loopback_get_stats64+0x74/0xa0
>>> [3391066.672020] Kernel unaligned access at TPC[7d6c18] loopback_get_stats64+0x78/0xa0
>>> [3391066.687282] Kernel unaligned access at TPC[7d6c1c] loopback_get_stats64+0x7c/0xa0
>>> [3391066.702573] Kernel unaligned access at TPC[7d6c20] loopback_get_stats64+0x80/0xa0
>>> [3391066.717858] Kernel unaligned access at TPC[8609dc] dev_get_stats+0x3c/0xe0
>> Yes, rtnl_fill_stats() probably has the same mistake.
>>
>> commit 550bce59baf3f3059cd4ae1e268f08f2d2cb1d5c
>> Author: Roopa Prabhu <roopa@cumulusnetworks.com>
>> Date:   Fri Apr 15 20:36:25 2016 -0700
>>
>>     rtnetlink: rtnl_fill_stats: avoid an unnecssary stats copy
>>     
>>     This patch passes netlink attr data ptr directly to dev_get_stats
>>     thus elimiating a stats copy.
>>     
>>     Suggested-by: David Miller <davem@davemloft.net>
>>     Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>>
>>
> David, if you revert the one in rtnl_fill_stats, i will take care of the dev_get_stats in RTM_GETSTATS in v6.

Don't need to revert, see my idea with the IFLA_PAD attribute. :-)
