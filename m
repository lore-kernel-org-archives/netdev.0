From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] tun, bpf: fix suspicious RCU usage in
 tun_{attach,detach}_filter
Date: Fri, 1 Apr 2016 01:31:52 +0200
Message-ID: <56FDB368.3000108@stressinduktion.org>
References: <56FD1512.70409@iogearbox.net>
 <20160331.152149.396188904137423987.davem@davemloft.net>
 <56FD795C.9090903@stressinduktion.org>
 <20160331.153630.1640223846173244431.davem@davemloft.net>
 <56FD7F0B.5090602@stressinduktion.org> <56FD9C39.6040703@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alexei.starovoitov@gmail.com,
	mkubecek@suse.cz, sasha.levin@oracle.com, jslaby@suse.cz,
	mst@redhat.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:36222 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753140AbcCaXb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 19:31:57 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id DC87C20894
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 19:31:56 -0400 (EDT)
In-Reply-To: <56FD9C39.6040703@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

On 31.03.2016 23:52, Daniel Borkmann wrote:
> On 03/31/2016 09:48 PM, Hannes Frederic Sowa wrote:
> [...]
>> Tightest solution would probably be to combine both patches.
>>
>> bool called_by_tuntap;
>>
>> old_fp = rcu_dereference_protected(sk->sk_filter, called_by_tuntap ?
>> lockdep_rtnl_is_held() : lockdep_sock_is_held());
>
> If I understand you correctly with combining them, you mean you'd still
> need the API change to pass the bool 'called_by_tuntap' down, right?

I actually decided to simply lock the sockets. So that there will always 
be a clear lock owner during the updates. I think this is cleaner. What 
do you think?

> If so, your main difference is, after all, to replace the
> sock_owned_by_user()
> with the lockdep_sock_is_held() construction instead, correct?

I just didn't do that part because we hold socket lock now.

> But then, isn't it already sufficient when you pass the bool itself down
> that 'demuxes' in this case between the sock_owned_by_user() vs
> lockdep_rtnl_is_held() check?

I just send out the patches, please have a look.

Thanks,
Hannes
