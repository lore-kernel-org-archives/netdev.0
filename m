From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] tun, bpf: fix suspicious RCU usage in tun_{attach,detach}_filter
Date: Thu, 31 Mar 2016 23:52:57 +0200
Message-ID: <56FD9C39.6040703@iogearbox.net>
References: <56FD1512.70409@iogearbox.net> <20160331.152149.396188904137423987.davem@davemloft.net> <56FD795C.9090903@stressinduktion.org> <20160331.153630.1640223846173244431.davem@davemloft.net> <56FD7F0B.5090602@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alexei.starovoitov@gmail.com,
	mkubecek@suse.cz, sasha.levin@oracle.com, jslaby@suse.cz,
	mst@redhat.com, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40668 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512AbcCaVxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 17:53:08 -0400
In-Reply-To: <56FD7F0B.5090602@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/31/2016 09:48 PM, Hannes Frederic Sowa wrote:
[...]
> Tightest solution would probably be to combine both patches.
>
> bool called_by_tuntap;
>
> old_fp = rcu_dereference_protected(sk->sk_filter, called_by_tuntap ? lockdep_rtnl_is_held() : lockdep_sock_is_held());

If I understand you correctly with combining them, you mean you'd still
need the API change to pass the bool 'called_by_tuntap' down, right?

If so, your main difference is, after all, to replace the sock_owned_by_user()
with the lockdep_sock_is_held() construction instead, correct?

But then, isn't it already sufficient when you pass the bool itself down
that 'demuxes' in this case between the sock_owned_by_user() vs
lockdep_rtnl_is_held() check?

Thanks,
Daniel
