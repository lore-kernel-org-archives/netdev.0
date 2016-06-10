From: Daniel Wagner <daniel.wagner@bmw-carit.de>
Subject: Re: [PATCH net-next] nfnetlink_queue: enable PID info retrieval
Date: Fri, 10 Jun 2016 08:40:34 +0200
Message-ID: <2ec75506-1ba0-5b16-4cd4-7b40cc969871@bmw-carit.de>
References: <1465505409-1232-1-git-send-email-saeedm@mellanox.com>
 <20160609213517.GA25288@breakpoint.cc> <5759EBF5.4010902@iogearbox.net>
 <5759FA28.3060900@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<netfilter-devel@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Andre Melkoumian <andre@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	<john.fastabend@gmail.com>, <hannes@stressinduktion.org>,
	<tj@kernel.org>, <viro@zeniv.linux.org.uk>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <5759FA28.3060900@iogearbox.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

> [ Cc'ing John, Daniel, et al ]
> 
> Btw, while I just looked at scm_detach_fds(), I think commits ...
> 
>  * 48a87cc26c13 ("net: netprio: fd passed in SCM_RIGHTS datagram not set
> correctly")
>  * d84295067fc7 ("net: net_cls: fd passed in SCM_RIGHTS datagram not set
> correctly")
> 
> ... might not be correct, maybe I'm missing something ...? Lets say
> process A
> has a socket fd that it sends via SCM_RIGHTS to process B. Process A was
> the
> one that called sk_alloc() originally. Now in scm_detach_fds() we
> install a new
> fd for process B pointing to the same sock (file's private_data) and
> above commits
> update the cached socket cgroup data for net_cls/net_prio to the new
> process B.
> So, if process A for example still sends data over that socket, skbs
> will then
> wrongly match on B's cgroup membership instead of A's, no?

I can't remember the details right now (need to read up again but I wont
have time till Wednesday).

>From your analysis I would say that is not the desired effect. A should
match against its own cgroup and not the one of B.

cheers,
daniel
