From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] bridge: fix seq check in br_mdb_dump()
Date: Tue, 11 Dec 2012 13:45:12 -0500 (EST)
Message-ID: <20121211.134512.1155163977355007483.davem@davemloft.net>
References: <1355141735-19576-1-git-send-email-amwang@redhat.com>
	<20121210.134602.1572570160819991716.davem@davemloft.net>
	<1355197772.13991.1.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.hengli.com.au,
	shemminger@vyatta.com, tgraf@suug.ch, brouer@redhat.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41591 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753769Ab2LKSpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 13:45:14 -0500
In-Reply-To: <1355197772.13991.1.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 11 Dec 2012 11:49:32 +0800

> On Mon, 2012-12-10 at 13:46 -0500, David Miller wrote:
>> From: Cong Wang <amwang@redhat.com>
>> Date: Mon, 10 Dec 2012 20:15:35 +0800
>> 
>> > From: Cong Wang <amwang@redhat.com>
>> > 
>> > In case of rehashing, introduce a global variable 'br_mdb_rehash_seq'
>> > which gets increased every time when rehashing, and assign
>> > net->dev_base_seq + br_mdb_rehash_seq to cb->seq.
>> > 
>> > In theory cb->seq could be wrapped to zero, but this is not
>> > easy to fix, as net->dev_base_seq is not visible inside
>> > br_mdb_rehash(). In practice, this is rare.
>> > 
>> > Cc: Herbert Xu <herbert@gondor.apana.org.au>
>> > Cc: Stephen Hemminger <shemminger@vyatta.com>
>> > Cc: "David S. Miller" <davem@davemloft.net>
>> > Cc: Thomas Graf <tgraf@suug.ch>
>> > Cc: Jesper Dangaard Brouer <brouer@redhat.com>
>> > Signed-off-by: Cong Wang <amwang@redhat.com>
>> 
>> No synchronization at all is applied to this variable, I can't
>> see how this is OK.
> 
> br_mdb_rehash() is protected by the multicast spinlock, so increasing
> this variable is protected by it, and reading the variable doesn't need
> locking. Am I missing anything? Or should we use atomic_t?

I missed that locking, ok, looks good.

Applied, thanks.
