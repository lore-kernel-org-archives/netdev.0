From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Fix race between access of desc and desc
 index
Date: Sun, 01 Nov 2015 12:04:04 -0500 (EST)
Message-ID: <20151101.120404.1795383010650058295.davem@davemloft.net>
References: <20151026221354.927.9237.stgit@tlendack-t1.amdoffice.net>
	<20151027.195007.1435133435434786670.davem@davemloft.net>
	<5630D234.3070600@amd.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53891 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbbKAREF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 12:04:05 -0500
In-Reply-To: <5630D234.3070600@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Wed, 28 Oct 2015 08:48:36 -0500

> On 10/27/2015 09:50 PM, David Miller wrote:
>> From: Tom Lendacky <thomas.lendacky@amd.com>
>> Date: Mon, 26 Oct 2015 17:13:54 -0500
>>
>>> During Tx cleanup it's still possible for the descriptor data to be
>>> read ahead of the descriptor index. A memory barrier is required
>>> between
>>> the read of the descriptor index and the start of the Tx cleanup loop.
>>> This allows a change to a lighter-weight barrier in the Tx transmit
>>> routine just before updating the current descriptor index.
>>>
>>> Since the memory barrier does result in extra overhead on arm64, keep
>>> the previous change to not chase the current descriptor value. This
>>> prevents the execution of the barrier for each loop performed.
>>>
>>> Suggested-by: Alexander Duyck <alexander.duyck@gmail.com>
>>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>>
>> Applied, thanks.
>>
> 
> Thanks David.  Could you queue this up for the 4.1 and 4.2 stable
> trees?

Ok, done.
