From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH net v2] L2TP:Adjust intf MTU,factor underlay L3,overlay L2
Date: Sat, 1 Oct 2016 17:50:39 +0100
Message-ID: <1cec5be4-0719-0dca-d3c6-8c794c867672@katalix.com>
References: <alpine.DEB.2.11.1609221341500.6975@duvvury30.eng.vyatta.net>
 <57ED30D7.6000009@katalix.com>
 <alpine.DEB.2.11.1609291913070.8509@duvvury48.eng.vyatta.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: kleptog@svana.org, netdev@vger.kernel.org, davem@redhat.com,
        linux-kernel@vger.kernel.org, nprachan@brocade.com,
        rshearma@brocade.com, dfawcus@brocade.com,
        stephen@networkplumber.org, acme@redhat.com, lboccass@brocade.com,
        bhong@brocade.com
To: "R. Parameswaran" <parameswaran.r7@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:49436 "EHLO mail.katalix.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750997AbcJAQuq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 1 Oct 2016 12:50:46 -0400
In-Reply-To: <alpine.DEB.2.11.1609291913070.8509@duvvury48.eng.vyatta.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/09/16 03:39, R. Parameswaran wrote:
>
>>> +	/* Adjust MTU, factor overhead - underlay L3 hdr, overlay L2 hdr*/
>>> +	if (tunnel->sock->sk_family == AF_INET)
>>> +		overhead += (ETH_HLEN + sizeof(struct iphdr));
>>> +	else if (tunnel->sock->sk_family == AF_INET6)
>>> +		overhead += (ETH_HLEN + sizeof(struct ipv6hdr));
>> What about options in the IP header? If certain options are set on the
>> socket, the IP header may be larger.
>>
> Thanks for the reply - It looks like IP options can only be 
> enabled through setsockopt on an application's socket (if there's any 
> other way to turn on IP options, please let me know - didn't see any 
> sysctl setting for transmit). This scenario would come 
> into picture when an application opens a raw IP or UDP socket such that it 
> routes into the L2TP logical interface.

No. An L2TP daemon (userspace) will open a socket for each tunnel that
it creates. Control and data packets use the same socket, which is the
socket used by this code. It may set any options on its sockets. L2TP
tunnel sockets can be created either by an L2TP daemon (managed tunnels)
or by ip l2tp commands (unmanaged tunnels).

> If you take the case of a plain IP (ethernet) interface, even if an
> application opened a socket turning on IP options, it would not change
> the MTU of the underlying interface, and it would not affect other 
> applications transacting packets on the same interface. I know its not an 
> exact parallel to this case, but since the IP option control is per 
> application, we probably should not factor it into the L2TP logical interface?
> We cannot affect other applications/processes running on the same L2TP 
> tunnel. Also, since the application  using IP options knows that it has turned 
> on IP options, maybe we can count on it to factor the size of the options 
> into the size of the payload it sends into the socket, or set the mtu on the 
> L2TP interface through config? 

No. See above.

>
> Other than this, I don't see keepalives or anything else in which the 
> kernel will source its own packet into the L2TP interface, outside of 
> an application injected packet - if there is something like that, please
> let me know. The user space L2TP daemon would probably fall in the 
> category of applications.
>
> thanks,
>
> Ramkumar 
>
>
