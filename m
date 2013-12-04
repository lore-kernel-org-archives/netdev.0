From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net_sched: Fail if missing mandatory action
 operation methods
Date: Tue, 03 Dec 2013 23:05:43 -0500 (EST)
Message-ID: <20131203.230543.2143790858411697753.davem@davemloft.net>
References: <1386080600-4067-6-git-send-email-jhs@mojatatu.com>
	<20131203.114834.106107332355850481.davem@davemloft.net>
	<529E7AA8.4030906@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, ebiederm@xmission.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988Ab3LDEFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 23:05:44 -0500
In-Reply-To: <529E7AA8.4030906@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Tue, 03 Dec 2013 19:43:20 -0500

> On 12/03/13 11:48, David Miller wrote:
> 
>> You are going to return with a lock held on error here.
>>
>> I was going to tell you not to do these fixups so late in the
>> function, inside of the write lock, there is no reason for it.
>>
>> You should do all of this operation handling at the top of
>> the function, before the write lock is taken.
>>
> 
> yikes;->
> do you want the whole set resent or the last one only?

BTW, you'll have to resend the whole set because your initial
patches put the !act->$(OP) checks inside the lock, and I'm
telling you here to put it outside the lock.

In fact, 3 of your patches need to change because of this.
