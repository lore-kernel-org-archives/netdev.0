From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: IPv6 connect() from site-local to global IPv6 address.
Date: Thu, 11 May 2006 21:54:52 +0900
Message-ID: <4463341C.7060907@miyazawa.org>
References: <1146862832.2766.54.camel@pmac.infradead.org>	 <20060506.091920.122414672.yoshfuji@linux-ipv6.org>	 <1146876802.2503.32.camel@shinybook.infradead.org>	 <20060506.113904.63157190.yoshfuji@linux-ipv6.org>	 <1146926830.2503.67.camel@shinybook.infradead.org>	 <445F7576.5080102@hp.com> <1147114080.2885.164.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	"=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyA=?= =?UTF-8?B?5ZCJ6Jek6Iux5piO?="
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 221x116x13x66.ap221.ftth.ucom.ne.jp ([221.116.13.66]:39346 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S1750815AbWEKMyk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 May 2006 08:54:40 -0400
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1147114080.2885.164.camel@hades.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I lost some mails on the list because of my network trouble.
This might not be a correct thread to reply. Sorry.

Anyway, I traced the probelem.

My test environment likes:

The host in my network could reach to the global network via NAT-T on IPv4.
But it could not reach to the global network on IPv6 because router did not have
the default route.
The radvd on the router advertised a global scope prefix for the hosts.
The hosts accordingly have a global scoped address.
DNS server returned both AAAA and A of the target host(server).

The router and the host is Ubuntu 5.10 with the kernel 2.6.16.9.

I tested with these steps:

1. I did "dig" to check that the host could got AAAA address.
2. I did ping6 to check that the host received dest unreach
    with no route from the router.
3. I run "evalution" and connected to my server which have AAAA and A.

It falled back to IPv4 and it could connect the server via IPv4 network.
It also falled back by "Time exceeded". My evolution version is 2.4.1.
Of course, when I added IPv6 default route, it connected via IPv6 network.

I think they works well as far as ICMPv6 error messages can be received.
I did not test in the environment in which ICMPv6 error messages are filtered.

Best regards,

David Woodhouse wrote:
> On Mon, 2006-05-08 at 09:44 -0700, Rick Jones wrote:
> 
>>Or get the applications fixed no?  Kludging around application bugs 
>>sounds a bit like the "Fram Oil Filter" commercial where the mechanic is 
>>grinning while he says "You can pay me now, or you can pay be later." As 
>>in pay for the slightly more expensive oil filter now, or engine repair 
>>later.
> 
> 
> Well, obviously. That's _why_ I want to deploy IPv6 and get it tested.
> But I used to be able to do this without actually breaking the network,
> and without being told to _stop_ running radvd because it breaks things.
> 
> 
>>Other than fixing the applications that only take the first response 
>>(isn't that a generic application bug going back nearly decades now? 
>>amazing how things stay the same isn't it) Can you run a caching-only 
>>name server at the edge that filters-out the IPv6 responses so your 
>>systems never see Global IPV6 responses?
> 
> 
> I don't think that kind of answer is going to be sufficient to persuade
> Uli to switch back from favouring IPv4 over IPv6. That's done the trick,
> admittedly -- by ensuring that we get _no_ testing of IPv6 unless we run
> with IPv6-only networking :)
> 

--
Kazunori Miyazawa
