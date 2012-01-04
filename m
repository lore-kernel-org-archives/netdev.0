From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bond_alb: do not disable BH under netpoll
Date: Wed, 04 Jan 2012 13:25:10 -0500 (EST)
Message-ID: <20120104.132510.1521809723158602749.davem@davemloft.net>
References: <1325643618-3051-1-git-send-email-maxim.uvarov@oracle.com>
	<20120103.214919.346240095248499387.davem@davemloft.net>
	<4F040A6F.2000002@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: maxim.uvarov@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51460 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754084Ab2ADSZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 13:25:15 -0500
In-Reply-To: <4F040A6F.2000002@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maxim Uvarov <maxim.uvarov@oracle.com>
Date: Wed, 04 Jan 2012 00:14:39 -0800

> On 03.01.2012 18:49, David Miller wrote:
>> From: Maxim Uvarov<maxim.uvarov@oracle.com>
>> Date: Tue,  3 Jan 2012 18:20:18 -0800
>>
>>> Do not disable BH if interrupts are already disabled
>>> (netpoll case).
>>> Signed-off-by: Maxim Uvarov<maxim.uvarov@oracle.com>
>> Barf...
>>
>> We should never use conditional locking like this.
> 
> 
> How about change spin_lock_bh  to spin_lock_irqsave at this place?

Then it's ambiguous whether it's a softirq safe lock or a hardirq
safe one.

It's just another way to make the locking inconsistent.
