From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 17 Jan 2005 23:53:05 +0100
Message-ID: <41EC41D1.1070704@tpack.net>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com> <1105363092.1041.146.camel@jzny.localdomain> <1105917038.1091.1041.camel@jzny.localdomain> <200501171404.19451.hasso@estpak.ee> <41EC3680.7060108@tpack.net> <41EC3894.9090304@pantasys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hasso Tepper <hasso@estpak.ee>, hadi@cyberus.ca,
        Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Buckingham <peter@pantasys.com>
In-Reply-To: <41EC3894.9090304@pantasys.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Peter Buckingham wrote:
> Hi,
> 
> Tommy Christensen wrote:
> 
>> A proper solution would take care of both these issues: "stale packets"
>> and "socket blocking". They are pretty much related.
>>
>> Using a socket for each interface *ought* not be needed.
>> Carrier detection sounds like a good thing in its own right.
> 
> 
> I came across this same problem with multicast/unicast with an e1000. 
> For a quick hack we just check to see whether the carrier is ok, if it's 
> not we just drop the packet. this might do some nasty things with tcp 
> and it may be better to check to see wither the socket buffer is full, 
> but this works for me here... (this is against a 2.6.9ish kernel)

Thanks for the input!

The downside of this solution is that it doesn't do anything with the
packets already queued for tx (in the qdisc queue and in the DMA ring).
OTOH it probably works just fine in real life (!).

Also, we may not want to handle all devices alike, as this patch does.

-Tommy
