From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] Configure bridge FDB ageing time using
 netlink.
Date: Mon, 16 Mar 2015 12:49:10 -0400 (EDT)
Message-ID: <20150316.124910.1918789012191520264.davem@davemloft.net>
References: <1426297229-21122-1-git-send-email-siva.mannem.lnx@gmail.com>
	<20150315.221312.1089494260964314644.davem@davemloft.net>
	<CA+CtxLTzqDh98bPQBS9AGdoi_-2=jSrnSJN3CL2bHE5nVoZ-cQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: siva.mannem.lnx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34388 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964856AbbCPQtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 12:49:16 -0400
In-Reply-To: <CA+CtxLTzqDh98bPQBS9AGdoi_-2=jSrnSJN3CL2bHE5nVoZ-cQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Siva Mannem <siva.mannem.lnx@gmail.com>
Date: Mon, 16 Mar 2015 12:12:39 +0530

> On Mon, Mar 16, 2015 at 7:43 AM, David Miller <davem@davemloft.net> wrote:
>> From: Siva Mannem <siva.mannem.lnx@gmail.com>
>> Date: Sat, 14 Mar 2015 07:10:29 +0530
>>
>>> This patch allows user to configure bridge's FDB ageing using
>>> netlink(for ex, iproute2). Allowed range is 10 seconds to 1000000 seconds
>>> as per ieee8021QBridgeFdbAgingTime.
>>>
>>> Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
>>
>> The behavior of br_changelink() leaves a lot to be desired, and this
>> change is making it worse.
>>
>> The range of the netlink attributes, the only thing that can cause
>> an error, should be validated for all attributes _first_.
>>
>> Because right now you can have several values change state,
>> then the last one has a range error, and an error is returned
>> without rolling back the state.
>>
>> This is terrible.
>>
>> When this happens the user has not reliable way to figure out
>> that some of the state changes it requested happened, and
>> exactly which ones those were.
>>
>> If an error is thrown we _MUST_ not make any state changes to
>> the bridge whatsoever.
> 
> Agree. Will work on it. Can it be a follow-on patch?

No, I don't want to apply your change as-is which makes the situation
worse.
