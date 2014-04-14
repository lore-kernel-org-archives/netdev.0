From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] A panic caused by null pointer dereference aftering
 updating to
Date: Mon, 14 Apr 2014 11:19:26 -0700
Message-ID: <1397499566.4222.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1397497204.4222.28.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140414.134901.2191404761213317963.davem@davemloft.net>
	 <1397498082.4222.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140414.140253.788885546068554928.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nasa4836@gmail.com, jchapman@katalix.com, edumazet@google.com,
	joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140414.140253.788885546068554928.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-04-14 at 14:02 -0400, David Miller wrote:

> BTW, it occurs to me that there may be some other spots in the output path
> that expect that if SKB is ETH_P_IP then skb->sk is IP socket.  For example
> somewhere in netfilter or packet classifier paths.
> 
> Just FYI... that was one of the things I was going to audit.

packet classifiers cannot have such assumptions for sure.

About iptunnel_xmit(), I do not think there is an issue, as we do not
enter ip_queue_xmit() on this path, but ip_local_out().

ip_local_out() doesn't use skb->sk , unless some netfilter module
uses this. I am not sure how the previous behavior could be useful in
this case, as all packets were sharing same socket ownership.

net/netfilter/xt_owner.c for example has better coverage if it can
really have a pointer to the user socket, not the internal socket used
by l2tp or vxlan tunnel.
