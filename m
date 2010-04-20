From: Franco Fichtner <franco@lastsummer.de>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Tue, 20 Apr 2010 14:48:53 +0200
Message-ID: <4BCDA2B5.4060609@lastsummer.de>
References: <1271452358.16881.4486.camel@edumazet-laptop>	 <1271520633.16881.4754.camel@edumazet-laptop>	 <20100419.130905.210660275.davem@davemloft.net>	 <20100419.132318.192086187.davem@davemloft.net>	 <1271709121.3845.94.camel@edumazet-laptop>	 <y2u412e6f7f1004191638mee9206dfoab7482bbff83e38d@mail.gmail.com>	 <1271743164.3845.128.camel@edumazet-laptop> <1271750198.3845.216.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.kissl.de ([213.239.241.64]:35110 "EHLO host64.kissl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753995Ab0DTMs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 08:48:58 -0400
In-Reply-To: <1271750198.3845.216.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> In case we compute a software skb->rxhash, we can generate a consistent
> hash : Its value will be the same in both flow directions.
>
> This helps some workloads, like conntracking, since the same state needs
> to be accessed in both directions.
>
> tbench + RFS + this patch gives better results than tbench with default
> kernel configuration (no RPS, no RFS)
>
> Also fixed some sparse warnings.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---

I thought about this for some time...

Do we really need the port numbers here at all? A simple
addr1^addr2 can provide a good enough pointer for
distribution amongst CPUs.

The real connection tracking is better done locally at the
corresponding CPU. That way a potential cache miss can be
avoided and the still needed hash calculation for
connection tracking will be offloaded.


Franco

