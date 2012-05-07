From: Deng-Cheng Zhu <dczhu@mips.com>
Subject: Re: [PATCH v2] RPS: Sparse connection optimizations - v2
Date: Mon, 7 May 2012 14:48:49 +0800
Message-ID: <4FA77051.20804@mips.com>
References: <1336035412-2161-1-git-send-email-dczhu@mips.com>	<CA+mtBx_J=fm3+k6_NzMH9KCdrYpZPwT2XBQe4r424eNDCKzazg@mail.gmail.com>	<4FA35A3D.8000205@mips.com> <CA+mtBx-CErRU=3ewkAjVrGN3dGzjsTz8Q-E8J+Xa+529OVEvwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<eric.dumazet@gmail.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dns0.mips.com ([12.201.5.70]:41957 "EHLO dns0.mips.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753485Ab2EGGs5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 02:48:57 -0400
In-Reply-To: <CA+mtBx-CErRU=3ewkAjVrGN3dGzjsTz8Q-E8J+Xa+529OVEvwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2012 11:31 PM, Tom Herbert wrote:
>> I think the mechanisms of rps_dev_flow_table and cpu_flow (in this
>> patch) are different: The former works along with rps_sock_flow_table
>> whose CPU info is based on recvmsg by the application. But for the tests
>> like what I did, there's no application involved.
>>
> While rps_sock_flow_table is currently only managed by recvmsg, it
> still is the general mechanism that maps flows to CPUs for steering.
> There should be nothing preventing you from populating and managing
> entries in other ways.

Well, even using rps_sock_flow_table to map the sparse flows to CPUs,
we still need a data structure to describe a single flow -- that's what
struct cpu_flow is doing. Besides, rps_sock_flow_table, by its meaning,
does not seem to make sense for our purpose. How about keeping the patch
as is but renaming struct cpu_flow to struct rps_sparse_flow? It's like:

---------------------------------------------
In include/linux/netdevice.h:

struct rps_sparse_flow {
        struct net_device *dev;
        u32 rxhash;
        unsigned long ts;
};

In net/core/dev.c:

static DEFINE_PER_CPU(struct rps_sparse_flow [CONFIG_NR_RPS_MAP_LOOPS],
rps_sparse_flow_table);
---------------------------------------------

The above looks similar to rps_dev_flow/rps_dev_flow_table, and we do
not necessarily go with rps_sock_flow_table.


Thanks,

Deng-Cheng
