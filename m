From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 2/9] net: filter: keep original BPF program
 around
Date: Sat, 13 Sep 2014 17:05:06 -0400 (EDT)
Message-ID: <20140913.170506.851550533823976026.davem@davemloft.net>
References: <1396029506-16776-3-git-send-email-dborkman@redhat.com>
	<1410492457.7106.72.camel@edumazet-glaptop2.roam.corp.google.com>
	<54128E1B.7020407@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ast@plumgrid.com, netdev@vger.kernel.org,
	xemul@parallels.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbaIMVFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 17:05:07 -0400
In-Reply-To: <54128E1B.7020407@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 12 Sep 2014 08:09:31 +0200

>> [PATCH] net: filter: fix possible use after free
>>
>> If kmemdup() fails, we free fp->orig_prog and return -ENOMEM
>>
>> sk_attach_filter()
>>   -> sk_filter_uncharge(sk, fp)
>>    -> sk_filter_release(fp)
>>     -> call_rcu(&fp->rcu, sk_filter_release_rcu)
>>      -> sk_filter_release_rcu()
>>       -> sk_release_orig_filter()
>>          fprog = fp->orig_prog; // not NULL, but points to freed memory
>> 	  kfree(fprog->filter); // use after free, potential corruption
>>            kfree(fprog); // double free or corruption
>>
>> Note: This was fixed in 3.17+ with commit 278571baca2a
>> ("net: filter: simplify socket charging")
>>
>> Found by AddressSanitizer
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Fixes: a3ea269b8bcdb ("net: filter: keep original BPF program around")
> 
> Thanks Eric!
> 
> Acked-by: Daniel Borkmann <dborkman@redhat.com>

Queued up for -stable, thanks.
