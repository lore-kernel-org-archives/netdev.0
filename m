From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] net: frag, avoid several CPUs grabbing
 same frag queue during LRU evictor loop
Date: Wed, 27 Mar 2013 13:10:06 -0400 (EDT)
Message-ID: <20130327.131006.2142647165754132919.davem@davemloft.net>
References: <20130327155238.15203.6688.stgit@dragon>
	<20130327155457.15203.69656.stgit@dragon>
	<1364400844.15753.18.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, fw@strlen.de,
	dborkman@redhat.com, hannes@stressinduktion.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58068 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398Ab3C0RKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 13:10:11 -0400
In-Reply-To: <1364400844.15753.18.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Mar 2013 09:14:04 -0700

> On Wed, 2013-03-27 at 16:55 +0100, Jesper Dangaard Brouer wrote:
>> The LRU list is protected by its own lock, since commit 3ef0eb0db4
>> (net: frag, move LRU list maintenance outside of rwlock), and
>> no-longer by a read_lock.
>> 
>> This makes it possible, to remove the inet_frag_queue, which is about
>> to be "evicted", from the LRU list head.  This avoids the problem, of
>> several CPUs grabbing the same frag queue.
>> 
>> Note, cannot remove the inet_frag_lru_del() call in fq_unlink()
>> called by inet_frag_kill(), because inet_frag_kill() is also used in
>> other situations.  Thus, we use list_del_init() to allow this
>> double list_del to work.
>> 
>> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>> ---
>> 
>>  net/ipv4/inet_fragment.c |    3 +++
>>  1 files changed, 3 insertions(+), 0 deletions(-)
>> 
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
