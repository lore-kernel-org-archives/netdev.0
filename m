From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: [PATCH 00/10]: Netfilter IPsec support
Date: Tue, 15 Nov 2005 16:50:46 +0100
Message-ID: <BAY103-F240FCD8D8AE36A95868233B25D0@phx.gbl>
References: <Pine.LNX.4.62.0511111243310.32138@kaber.coreworks.de>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
In-Reply-To: <Pine.LNX.4.62.0511111243310.32138@kaber.coreworks.de>
To: kaber@trash.net
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

How are handled NAT-T packets (udp/4500) with these patches?

Patrick McHardy wrote:

>
>On Fri, 11 Nov 2005, Gerd v. Egidy wrote:
>
>>Hi,
>>
>>>This is the latest set patches for netfilter IPsec support.
>>>The use of netif_rx for the innermost SA if it used transport
>>>mode has been replaced by explicit NF_HOOK calls in
>>>xfrm{4,6}_input.c.
>>
>>Could you please describe the solution you implemented a bit more? There 
>>was
>>just so many back and forth that I'm confused now.
>
>OK, some explanation. In tunnel mode, packets go through the stack
>again after decapsulation and hit the PRE_ROUTING and LOCAL_IN or FORWARD
>hook, depending on if it is a local packet or is forwarded. For symetry,
>there are now some additional hooks on the output path which pass the
>packet through LOCAL_OUT and POST_ROUTING after tunnel mode transforms.
>This part behaves just as any other tunnel. Transport mode is special,
>we usually don't want to see packets before or after transport mode
>transforms except if it was the plain text packet (the transport
>mode SA is the innermost SA of the bundle). On the output path this
>already works because packets always hit netfilter before reaching
>the transforms, on the input path packets are manually passed through
>PRE_ROUTING and INPUT in this case. For NAT we do two things:
>when a packet is NATed after already beeing routed (including
>the xfrm lookup), it is routed again. If an incoming packet is NATed
>before the policy check, the policy check reconstructs how the packet
>looked before NAT.
>
>>
>>If I use it with iptables, do the transport mode packets go through INPUT 
>>and
>>OUTPUT twice, decrypted and encrypted?
>
>Yes, if the transport mode transform in the innermost transform
>of the bundle (or the only one).
>
>>
>>If I use it with iptables, do the tunnel mode packets go through FORWARD 
>>or
>>INPUT and OUTPUT twice, decrypted and encrypted?
>
>Yes.
>
>>Can I do NAT in tunnel and transport mode?
>
>Yes, even NATing forwarded packets and protecting them using a transport
>mode SA works.
>
>>what about the policy match patches, why are they only posted "for
>>completeness" and as 11/12 of 10? Aren't they ready yet?
>
>They should be fine.
>
