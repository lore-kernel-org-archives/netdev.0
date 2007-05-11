From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] tbf scheduler: TSO support
Date: Fri, 11 May 2007 20:13:45 +0200
Message-ID: <4644B259.5060400@trash.net>
References: <46431687.7060600@trash.net>	<20070510.141344.127196214.davem@davemloft.net>	<4643C115.3020802@trash.net> <20070511.130142.16832866.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Hirokazu Takahashi <taka@valinux.co.jp>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20070511.130142.16832866.taka@valinux.co.jp>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hirokazu Takahashi wrote:
> I think the concept of TBF is quit good but the userspace tools have
> become old that it doesn't fit to Gb ethernet environment.
> The tools should be updated to care about much faster network and
> GbE jumbo frames. I agree with you at this point.
> 
> On the other hand, handling TSO packet should be a kernel issue.
> A TSO packet is logically just a multiple segmented packet
> including several ordinary packets. This feature should be kept
> invisible from userspace.


Putting aside this question, this cannot work properly without userspace
since the rate table is only built for the given MTU. Your patch tries
to work around that by summing up the result of L2T in q->max_size
steps, which gives incorrect results with MPU or overhead settings.

I think we can only do two things without userspace support:

- disable TSO (not a good idea)
- split the skb into q->max_size chunks on dequeue

The later would allow people to take full advantage of TSO with properly
configured TBF, but it would still at least work with a too small mtu
value.

