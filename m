From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] tun, bpf: fix suspicious RCU usage in tun_{attach,detach}_filter
Date: Thu, 31 Mar 2016 14:16:18 +0200
Message-ID: <56FD1512.70409@iogearbox.net>
References: <755ee9ec1f6d2229be41806964b372548e4b7586.1459382574.git.daniel@iogearbox.net>	 <20160331011840.GA50846@ast-mbp.thefacebook.com>	 <20160331050115.GA21665@unicorn.suse.cz>	 <20160331050808.GA56499@ast-mbp.thefacebook.com>	 <20160331052232.GB21665@unicorn.suse.cz>	 <20160331054301.GA57227@ast-mbp.thefacebook.com>	 <56FD0B79.5020007@iogearbox.net> <1459425558.6473.229.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Michal Kubecek <mkubecek@suse.cz>, davem@davemloft.net,
	sasha.levin@oracle.com, jslaby@suse.cz, mst@redhat.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52934 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbcCaMQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 08:16:28 -0400
In-Reply-To: <1459425558.6473.229.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/31/2016 01:59 PM, Eric Dumazet wrote:
> On Thu, 2016-03-31 at 13:35 +0200, Daniel Borkmann wrote:
>
>> +static inline bool sock_owned_externally(const struct sock *sk)
>> +{
>> +	return sk->sk_flags & (1UL << SOCK_EXTERNAL_OWNER);
>> +}
>> +
>
> Have you reinvented sock_flag(sl, SOCK_EXTERNAL_OWNER) ? ;)
>
> Anyway, using a flag for this purpose sounds overkill to me.

Right.

> Setting it is a way to 'fool' lockdep anyway...

Yep, correct, we'd be fooling the tun case, so this diff doesn't
really make it any better there.

Thanks,
Daniel
