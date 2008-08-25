From: David Miller <davem@davemloft.net>
Subject: Re: Unexpected source address selection in routing
Date: Sun, 24 Aug 2008 17:31:46 -0700 (PDT)
Message-ID: <20080824.173146.28446297.davem@davemloft.net>
References: <alpine.LNX.1.10.0808241936410.22921@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: jengelh@medozas.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.1.10.0808241936410.22921@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>
Date: Sun, 24 Aug 2008 19:39:52 -0400 (EDT)

> It appears that the routing code selects the outgoing source address to 
> use for packets is chosen when the socket is established instead of
> at routing time.
> 
> The following presents a test case for "unexpected" (from a user's 
> perspective) behavior.
> 
> Is there any way to make it behave as a user would expect?

No matter when we had made the routing lookup, we would
have ended up with what you see the kernel doing.

The route is looked up long before netfilter even sees
the packets.

The source address selection at the socket level can only "see" the
original destination address and therefore makes the source address
selection using that original destination address.

After iptables mangles things, the packet is rerouted but source
address selection and IP header source address mangling are not going
to occur.
