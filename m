From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] A panic caused by null pointer dereference aftering
 updating to
Date: Mon, 14 Apr 2014 14:02:53 -0400 (EDT)
Message-ID: <20140414.140253.788885546068554928.davem@davemloft.net>
References: <1397497204.4222.28.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140414.134901.2191404761213317963.davem@davemloft.net>
	<1397498082.4222.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nasa4836@gmail.com, jchapman@katalix.com, edumazet@google.com,
	joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397498082.4222.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Apr 2014 10:54:42 -0700

> On Mon, 2014-04-14 at 13:49 -0400, David Miller wrote:
> 
>> Yep that would handle the l2tp cases, but vxlan needs something different
>> since it goes through iptunnel_xmit().
>> 
>> So perhaps as a quick fix we can add an 'sk' arg to both
>> ip_queue_xmit() and ip_local_out().
> 
> Right, I am working on this right now.

Thanks a lot Eric.

BTW, it occurs to me that there may be some other spots in the output path
that expect that if SKB is ETH_P_IP then skb->sk is IP socket.  For example
somewhere in netfilter or packet classifier paths.

Just FYI... that was one of the things I was going to audit.
