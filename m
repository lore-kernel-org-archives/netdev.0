From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: cgroup matches in INPUT chain
Date: Fri, 20 Mar 2015 21:18:28 +0100
Message-ID: <550C8094.5000508@iogearbox.net>
References: <550B1852.2020209@zonque.org> <20150319185807.GA3845@breakpoint.cc> <550C2753.9020608@zonque.org> <20150320161111.GA11498@breakpoint.cc> <550C4901.4070001@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Perevalov <a.perevalov@samsung.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>
To: Daniel Mack <daniel@zonque.org>, Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60784 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbbCTUSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 16:18:38 -0400
In-Reply-To: <550C4901.4070001@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2015 05:21 PM, Daniel Mack wrote:
> On 03/20/2015 05:11 PM, Florian Westphal wrote:
>> Daniel Mack <daniel@zonque.org> wrote:
>>> In my simple test setup, when skbs are dequeued by process_backlog(),
>>> they have skb->_skb_refdst set, and hence ip_rcv_finish() does not call
>>> into early_demux() prior to iterating the INPUT chain:
>>
>> Yes, because we already have a route set.
>>
>> Are we talking about loopback?
>
> I'm testing this on the lookback device, but I've seen similar behavior
> on external interfaces too. However, I fail to see a pattern in that.
>
>> What are you trying to do?
>
> Basically, I have a simple server that listens to a TCP port, accepts a
> connection, writes out a short string and closes the connection again.
> The process is put into a netcls cgroup controller, and a classid is
> assigned to it, and I'm trying catch all traffic sent to it (regardless
> of the interface in use) with a netfilter rule.
>
> However, that doesn't work, because under the described circumstances,
> the match callback of the cgroup netfilter module is always called with
> an skb that has no sk set.

Thanks for the report Daniel. I see the same here, so let me look
closer into it on Monday and get back to you. Looks like commit
a00e76349f3564bb is not sufficient.

Cheers,
Daniel
