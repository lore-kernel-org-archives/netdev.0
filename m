From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tun, bpf: fix suspicious RCU usage in
 tun_{attach,detach}_filter
Date: Thu, 31 Mar 2016 15:21:49 -0400 (EDT)
Message-ID: <20160331.152149.396188904137423987.davem@davemloft.net>
References: <56FD0B79.5020007@iogearbox.net>
	<1459425558.6473.229.camel@edumazet-glaptop3.roam.corp.google.com>
	<56FD1512.70409@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alexei.starovoitov@gmail.com,
	mkubecek@suse.cz, sasha.levin@oracle.com, jslaby@suse.cz,
	mst@redhat.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57665 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756317AbcCaTVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 15:21:51 -0400
In-Reply-To: <56FD1512.70409@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 31 Mar 2016 14:16:18 +0200

> On 03/31/2016 01:59 PM, Eric Dumazet wrote:
>> On Thu, 2016-03-31 at 13:35 +0200, Daniel Borkmann wrote:
>>
>>> +static inline bool sock_owned_externally(const struct sock *sk)
>>> +{
>>> +	return sk->sk_flags & (1UL << SOCK_EXTERNAL_OWNER);
>>> +}
>>> +
>>
>> Have you reinvented sock_flag(sl, SOCK_EXTERNAL_OWNER) ? ;)
>>
>> Anyway, using a flag for this purpose sounds overkill to me.
> 
> Right.
> 
>> Setting it is a way to 'fool' lockdep anyway...
> 
> Yep, correct, we'd be fooling the tun case, so this diff doesn't
> really make it any better there.

I like the currently proposed patch where TUN says that RTNL is what
the synchronizing element is.

Maybe we could make a helper of some sort but since we only have once
case like this is just overkill.

Alexei, do you really mind if I apply Danile's patch?

Thanks.
