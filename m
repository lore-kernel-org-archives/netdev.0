From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Unexpected source address selection in routing
Date: Sun, 24 Aug 2008 21:28:10 -0400 (EDT)
Message-ID: <alpine.LNX.1.10.0808242126540.22921@fbirervta.pbzchgretzou.qr>
References: <alpine.LNX.1.10.0808241936410.22921@fbirervta.pbzchgretzou.qr> <20080824.173146.28446297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080824.173146.28446297.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sunday 2008-08-24 20:31, David Miller wrote:
>
>> It appears that the routing code selects the outgoing source address to 
>> use for packets is chosen when the socket is established instead of
>> at routing time.
>> 
>> The following presents a test case for "unexpected" (from a user's 
>> perspective) behavior.
>> 
>> Is there any way to make it behave as a user would expect?
>
>No matter when we had made the routing lookup, we would have ended
>up with what you see the kernel doing.
>
>The route is looked up long before netfilter even sees the packets.
>
>The source address selection at the socket level can only "see" the
>original destination address and therefore makes the source address
>selection using that original destination address.

That's what I thought. With IPv4, one can cheat and use
SNAT/MASQUERADE, but what about IPv6? (Other than using the RAWNAT
extension, which bypasses netfilter connection tracking.)
