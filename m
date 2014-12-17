From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH net-next 3/5] tcp: Add a few more tracepoints for
 tcp tracer
Date: Wed, 17 Dec 2014 08:59:40 -0700
Message-ID: <5491A86C.5030207@gmail.com>
References: <1418608606-1569264-1-git-send-email-kafai@fb.com> <1418608606-1569264-4-git-send-email-kafai@fb.com> <20141217153349.GG11607@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: Arnaldo Carvalho de Melo <acme@kernel.org>,
	Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:45227 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbaLQP7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 10:59:45 -0500
Received: by mail-pa0-f51.google.com with SMTP id ey11so16732998pad.10
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 07:59:44 -0800 (PST)
In-Reply-To: <20141217153349.GG11607@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/14 8:33 AM, Arnaldo Carvalho de Melo wrote:
>
> On a random RHEL7 kernel I had laying around on a test machine:
>
> [root@ssdandy ~]# perf probe -L tcp_sacktag_write_queue | head -20
> <tcp_sacktag_write_queue@/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp_input.c:0>
>        0  tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
>           			u32 prior_snd_una)
>        2  {
>           	struct tcp_sock *tp = tcp_sk(sk);
>        4  	const unsigned char *ptr = (skb_transport_header(ack_skb) +
>           				    TCP_SKB_CB(ack_skb)->sacked);
>           	struct tcp_sack_block_wire *sp_wire = (struct tcp_sack_block_wire *)(ptr+2);
>           	struct tcp_sack_block sp[TCP_NUM_SACKS];
>           	struct tcp_sack_block *cache;
>           	struct tcp_sacktag_state state;
>           	struct sk_buff *skb;
>       11  	int num_sacks = min(TCP_NUM_SACKS, (ptr[1] - TCPOLEN_SACK_BASE) >> 3);
>           	int used_sacks;
>           	bool found_dup_sack = false;
>           	int i, j;
>           	int first_sack_index;
>
>       17  	state.flag = 0;
>       18  	state.reord = tp->packets_out;

But there are limitations/hassles with this approach. For starters I 
believe it requires vmlinux on box. The products I work on do not have 
vmlinux available in the runtime environment. I recall someone (Masami?) 
suggesting the ability to write the probe data to a file (ie., create 
the probe definition off box) and load the file to create the probe, so 
yes a solvable problem.

But with this approach it could very be that the function name and 
variable names differ with kernel version and that makes it hard to 
impossible to create a set of analysis commands.

David
