From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: release lock after each bucket in
 vxlan_cleanup
Date: Wed, 27 May 2015 14:31:30 -0400 (EDT)
Message-ID: <20150527.143130.381509373001563210.davem@davemloft.net>
References: <1432626124-24676-1-git-send-email-sorin@returnze.ro>
	<CAHA+R7Md7vGJj_6e8P7iB3j-gaax6H37OQ_9N26KUwjgbWHz_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sorin@returnze.ro, netdev@vger.kernel.org, sdumitru@ixiacom.com
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584AbbE0Sbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:31:33 -0400
In-Reply-To: <CAHA+R7Md7vGJj_6e8P7iB3j-gaax6H37OQ_9N26KUwjgbWHz_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Wed, 27 May 2015 10:44:26 -0700

> On Tue, May 26, 2015 at 12:42 AM, Sorin Dumitru <sorin@returnze.ro> wrote:
>> We're seeing some softlockups from this function when there
>> are a lot fdb entries on a vxlan device. Taking the lock for
>> each bucket instead of the whole table is enough to fix that.
>>
> 
> Hmm, then the spinlock could be moved into each bucket, right?

Just because this one big one-time cleanup operation holds the lock
for a long time, doesn't justify making it more granular.
