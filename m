From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: add complete rcu protection around np->opt
Date: Wed, 02 Dec 2015 23:38:21 -0500 (EST)
Message-ID: <20151202.233821.139368757119113563.davem@davemloft.net>
References: <1448730683.24696.94.camel@edumazet-glaptop2.roam.corp.google.com>
	<1448731434.24696.97.camel@edumazet-glaptop2.roam.corp.google.com>
	<1448854677.24696.117.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, vyasevich@gmail.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com, wdauchy@gmail.com,
	rweikusat@mobileactivedefense.com, syzkaller@googlegroups.com,
	kcc@google.com, glider@google.com, sasha.levin@oracle.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448854677.24696.117.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 29 Nov 2015 19:37:57 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> This patch addresses multiple problems :
> 
> UDP/RAW sendmsg() need to get a stable struct ipv6_txoptions
> while socket is not locked : Other threads can change np->opt
> concurrently. Dmitry posted a syzkaller
> (http://github.com/google/syzkaller) program desmonstrating
> use-after-free.
> 
> Starting with TCP/DCCP lockless listeners, tcp_v6_syn_recv_sock()
> and dccp_v6_request_recv_sock() also need to use RCU protection
> to dereference np->opt once (before calling ipv6_dup_options())
> 
> This patch adds full RCU protection to np->opt
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
