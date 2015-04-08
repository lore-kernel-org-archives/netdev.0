From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Prevent UDP tunnels from operating on garbage
 socket
Date: Wed, 08 Apr 2015 16:03:03 -0400 (EDT)
Message-ID: <20150408.160303.1536044900311728443.davem@davemloft.net>
References: <20150406.235118.65925113152002205.davem@davemloft.net>
	<CALx6S36f8SQQoNvzPyCNk4=0LbH4Od6ZtdDn0DCA2sZGZHMx2g@mail.gmail.com>
	<1428406053.3932555.250169221.75848497@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	jiri@resnulli.us
To: hannes@stressinduktion.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428406053.3932555.250169221.75848497@webmail.messagingengine.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 07 Apr 2015 13:27:33 +0200

> Also, I saw one inconsistency with sk_bound_dev_if in netfilter which
> doesn't get solved by this patchset (it uses skb->sk->sk_bound_dev_if
> unconditionally).

I looked at this quickly, and it'll take a bit of (mechanical) work to
resolve.  Basically you have to get the socket down to ip_route_me_harder()
and sometimes that code path is coming from that XT targets, which don't
take the nf_hook_state as an argument or anything like that (yet).
