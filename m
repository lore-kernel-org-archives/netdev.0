From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ipv4: add IPPROTO_ICMP socket kind
Date: Tue, 10 May 2011 12:15:50 -0700 (PDT)
Message-ID: <20110510.121550.112583080.davem@davemloft.net>
References: <20110412.142534.183049889.davem@davemloft.net>
	<20110510180957.GA3262@albatros>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: solar@openwall.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, peak@argo.troja.mff.cuni.cz,
	kees.cook@canonical.com, dan.j.rosenberg@gmail.com,
	eugene@redhat.com, nelhage@ksplice.com, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: segoon@openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110510180957.GA3262@albatros>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasiliy Kulikov <segoon@openwall.com>
Date: Tue, 10 May 2011 22:09:59 +0400

In net-next-2.6 we're trying to get rid of uses of route identity
information, and also the types used for flow lookup keys are
completely different.  This code won't compile as-is.

> +	{
> +		struct flowi fl = { .oif = ipc.oif,

This should be "struct flowi4 fl4", declare it at the top
level of the function so you can get at the fully resolved
key values later in this function.

Then use "flowi4_init_output(...) to initialize the flow instead of
this explicit assignment.

> +	if (!ipc.addr)
> +		ipc.addr = rt->rt_dst;

Replase rt->rt_dst with fl4.daddr

> +	err = ip_append_data(sk, ping_getfrag, &pfh, len,
> +			0, &ipc, &rt,
> +			msg->msg_flags);

ip_append_data() now takes a flowi4 key pointer as an argument, so
you'll need to pass "&fl4" in.

A lot has changed in this area, your code won't even compile, so
please adjust your patch to fit net-next-2.6 as needed, perhaps
using net/ipv4/raw.c and net/ipv4/udp.c as a guide.

Thanks.
