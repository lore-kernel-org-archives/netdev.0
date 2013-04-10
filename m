From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [RFC PATCH ipsec] xfrm: use the right dev to fill xdst
Date: Wed, 10 Apr 2013 14:39:39 +0300
Message-ID: <51654F7B.20805@ixiacom.com>
References: <20130409124735.GA21448@secunet.com> <20130409.132138.1712236757714558152.davem@davemloft.net> <CAEnQRZB4ESaVwgiTScQyTp=Yo16aUhuonMJS7KzfNbs3zRoLFA@mail.gmail.com> <20130409.133329.293030369317491509.davem@davemloft.net> <CAEnQRZBLLUviOrgQxzA=X9Q6YpSq9vf8kBtgPxeTiitS+P-oFw@mail.gmail.com> <20130410112900.GC21448@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <nicolas.dichtel@6wind.com>,
	<herbert@gondor.apana.org.au>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe005.messaging.microsoft.com ([213.199.154.143]:21622
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752322Ab3DJLhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 07:37:14 -0400
In-Reply-To: <20130410112900.GC21448@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2013 02:29 PM, Steffen Klassert wrote:
> On Tue, Apr 09, 2013 at 09:18:33PM +0300, Daniel Baluta wrote:
>> On Tue, Apr 9, 2013 at 8:33 PM, David Miller<davem@davemloft.net>  wrote:
>>> From: Daniel Baluta<daniel.baluta@gmail.com>
>>> Date: Tue, 9 Apr 2013 20:31:30 +0300
>>>
>>>> As I mentioned earlier in this thread we are using some custom
>>>> kernel modules that create the interfaces.
>>>>
>>>> It's likely that these interfaces, for memory saving purposes, to
>>>> skip attaching ipv6 device information.
>>> So this is not an upstream bug.
>> Correct.
>>
>> With conditions mentioned by Steffen, in upstream, each net_device
>> has an in6_device assigned so we won't hit the problem.
>>
> We have an in6_device assigned in almost all of the cases, but I doubt
> it is always the right one.
>
> Let's say we want to tunnel ipv6 over ipv4. We do an ipv6 route lookup
> that returns a route with output device, say eth0. With that route,
> we do an IPsec route lookup and we get an ipv4 tunnel route with output
> device eth1.
>
> When we create the xfrm_dst in xfrm_bundle_create(), we copy the
> informations from the original ipv6 route, because we pass the new
> allocated IPsec route back to the ipv6 layer. But the device is taken
> from the ipv4 tunnel route (eth1 instead of eth0), so we pass a
> dst_entry with a ipv4 device assigned to the ipv6 layer.
>
> For that reason, xfrm6_fill_dst() complains about a NULL in6_device,
> when the mtu of the ipv4 device (passed to xfrm6_fill_dst()) is
> below IPV6_MIN_MTU.
>
> I think there is to fix something, but this needs some more research
> before we can do anything about that.
>
I will try  to further look into this. If you have any scripts
that can ease IPSec tunnels setup please do share.

thanks,
daniel.
