From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Fix br_should_learn to check vlan_enabled
Date: Tue, 16 Sep 2014 12:16:43 -0400 (EDT)
Message-ID: <20140916.121643.233106338483972364.davem@davemloft.net>
References: <20140915.173849.609066505150727105.davem@davemloft.net>
	<541813AB.2060301@lab.ntt.co.jp>
	<54184303.9070503@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: makita.toshiaki@lab.ntt.co.jp, vyasevich@gmail.com,
	netdev@vger.kernel.org, vyasevic@redhat.com
To: toshiaki.makita1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753050AbaIPQQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 12:16:45 -0400
In-Reply-To: <54184303.9070503@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Date: Tue, 16 Sep 2014 23:02:43 +0900

> (14/09/16 (火) 19:40), Toshiaki Makita wrote:
>> On 2014/09/16 6:38, David Miller wrote:
>>> From: Vladislav Yasevich <vyasevich@gmail.com>
>>> Date: Mon, 15 Sep 2014 15:24:26 -0400
>>>
>>>> As Toshiaki Makita pointed out, the BRIDGE_INPUT_SKB_CB will
>>>> not be initialized in br_should_learn() as that function
>>>> is called only from br_handle_local_finish().  That is
>>>> an input handler for link-local ethernet traffic so it perfectly
>>>> correct to check br->vlan_enabled here.
>>>>
>>>> Reported-by: Toshiaki Makita<toshiaki.makita1@gmail.com>
>>>> Fixes: 20adfa1 bridge: Check if vlan filtering is enabled only once.
>>>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>>>
>>> Applied, thanks Vlad.
>>
>> Hi David,
>>
>> Could you queue this for -stable as well?
>> Without this, FDB can be poisoned by disallowed ports.
>> (the same problem as stated in e0d7968ab6c8 "bridge: Prevent insertion
>> of FDB entry with disallowed vlan")
> 
> I'm sorry, I was confusued.
> This doesn't cause that problem, because if vlan_filtered is 0, fdb is
> always updated with vid 0. Such an entry is never used as long as
> vlan_filtering is enabled.
> Please ignore my previous mail.

Ok.
