From: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Subject: Re: [PATCH] rionet: Don't try to corrupt skbuff assigning data
 pointer directly
Date: Fri, 3 Jul 2015 09:24:27 +0200
Message-ID: <559638AB.9010707@nokia.com>
References: <5593E497.40804@nokia.com>
 <20150702.121204.1674202660204278751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mporter@kernel.crashing.org,
	alexandre.bounine@idt.com, frank.kunz@nokia.com,
	marek.krzyzowski@nokia.com
To: ext David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:35218 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754420AbbGCHY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 03:24:57 -0400
In-Reply-To: <20150702.121204.1674202660204278751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On 02/07/15 21:12, ext David Miller wrote:
>> It's not allowed to assign data pointer of skbuff directly, this makes no sense
>> > if the assigned pointer is the very same as already existing one, or it brakes
>> > all the pointer arithmetics in all other cases. We cannot do better as just
>> > compare them and report BUG() in case of mismatch.
>> > 
>> > Signed-off-by: Alexander Sverdlin <alexander.sverdlin@nokia.com>
> BUG takes the entire machine out, which is worse than corrupting the
> skb->data
> 
> If you really want to assert this condition, do it in a way that
> doesn't kill the entire machine.

In fact, the machine goes down, some milliseconds later, but because of the following
inconsistencies, which are misleading. The function has no way to signal an error and
this line of code is simply wrong. To prevent others from copying this error, we can
simply delete it. Would it be fine from your PoV?

-- 
Best regards,
Alexander Sverdlin.
