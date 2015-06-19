From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 00/15] Simplify netfilter and network namespaces
Date: Fri, 19 Jun 2015 09:24:45 -0500
Message-ID: <87lhff22tu.fsf@x220.int.ebiederm.org>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
	<alpine.LFD.2.11.1506172216440.2649@ja.home.ssi.bg>
	<87wpz25a2q.fsf@x220.int.ebiederm.org>
	<alpine.LFD.2.11.1506180055030.3621@ja.home.ssi.bg>
	<87fv5p2hzg.fsf@x220.int.ebiederm.org>
	<alpine.LFD.2.11.1506182210240.1659@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1506182210240.1659@ja.home.ssi.bg> (Julian
	Anastasov's message of "Thu, 18 Jun 2015 22:21:15 +0300 (EEST)")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julian Anastasov <ja@ssi.bg> writes:

> 	Hello,
>
> On Thu, 18 Jun 2015, Eric W. Biederman wrote:
>
>> My incremental patch for ipvs on top of everything else I have pushed
>> out looks like this:
>> 
>> From: "Eric W. Biederman" <ebiederm@xmission.com>
>> Date: Fri, 12 Jun 2015 18:34:12 -0500
>> Subject: [PATCH] ipvs: Pass struct net down to where it is needed and used
>> 
>> Pass struct net down to where it is used and stop guessing
>> which network namespace should be used.
>
> 	At first look patch is ok. But I'm not sure
> for the changes in ip_vs_xmit.c. Can you explain in
> 2-3 lines, when can we see different netns? Is it when
> packet is forwarded to output device and it is part from
> another netns?
>
> 	I'm asking because these __ip_vs_get_out_rt*
> calls in ip_vs_xmit.c can reroute packet to another
> device...

The driver was ensure_mtu_is_adequate where in one half
of the function we have skb_net another half we have 
dev_net(dst_skb(skb)->dev).    That is goofy.

That gets replaced by ip_vs_conn_net(cp).

In practice today I don't see that there are differences in
network namespaces today.

Moving forward I hope to be able to route packets out to network devices
in different network namespaces. It is a massive optimization that
doesn't need much code to support.  Once that optimization is in place
deriving the network namespace from the output device will not work.

I believe using ip_vs_conn_net(cp) is a simple rule that is easy to
understand and easy to implement correctly on the output path.

> 	Also, skb_sknet is another candidate for removal.
> But I can take care about it after your changes are
> pushed...

*nod*

Eric
--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
