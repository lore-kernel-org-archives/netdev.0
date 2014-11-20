From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: use skb_get_hash_raw instead of
 skb_get_hash in set_rps_cpu
Date: Wed, 19 Nov 2014 20:57:21 -0500 (EST)
Message-ID: <20141119.205721.512733494816813023.davem@davemloft.net>
References: <1416391244-27390-1-git-send-email-_govind@gmx.com>
	<20141119.191610.1447608233879904907.davem@davemloft.net>
	<CA+mtBx9K61KmguzQBWNbnmesCvWtzh_SjjbjedkgxN6p4Oay4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: _govind@gmx.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001AbaKTB5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 20:57:23 -0500
In-Reply-To: <CA+mtBx9K61KmguzQBWNbnmesCvWtzh_SjjbjedkgxN6p4Oay4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 19 Nov 2014 16:51:40 -0800

> On Wed, Nov 19, 2014 at 4:16 PM, David Miller <davem@davemloft.net> wrote:
>> From: Govindarajulu Varadarajan <_govind@gmx.com>
>> Date: Wed, 19 Nov 2014 15:30:44 +0530
>>
>>> In set_rps_cpu, we call skb_get_hash to get the hash of skb. The caller
>>> get_rps_cpu has already determined the hash of skb by calling skb_get_hash.
>>>
>>> Since get_rps_cpu is the only caller of set_rps_cpu, we can use skb_get_hash_raw
>>>
>>> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
>>
>> Tom, please review.  And if you agree with this change, you'll need to
>> be spinning your flow_id change relative to this I guess since it overlaps.
>>
> We should probably pass hash as an argument in set_rps_cpu. It's only
> called from once place and the rflow is specifically chosen based on
> hash computed by caller-- don't want any ambiguity there.

Yep, that sounds a lot less error prone.
