From: Eli Cooper <elicooper@gmx.com>
Subject: Re: [PATCH v2] ipv6: Use inbound ifaddr as source addresses for
 ICMPv6 errors
Date: Mon, 29 Aug 2016 02:34:32 +0800
Message-ID: <446b91c5-c19c-c294-9644-670bc6313b48@gmx.com>
References: <20160828033406.11269-1-elicooper@gmx.com>
 <20160828171800.gtdo764pvoyhgim4@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:49470 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751220AbcH1SfL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 28 Aug 2016 14:35:11 -0400
In-Reply-To: <20160828171800.gtdo764pvoyhgim4@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,


On 2016/8/29 1:18, Guillaume Nault wrote:
> On Sun, Aug 28, 2016 at 11:34:06AM +0800, Eli Cooper wrote:
>> According to RFC 1885 2.2(c), the source address of ICMPv6
>> errors in response to forwarded packets should be set to the
>> unicast address of the forwarding interface in order to be helpful
>> in diagnosis.
>>
> FWIW, this behaviour has been deprecated ten years ago by RFC 4443:
> "The address SHOULD be chosen according to the rules that would be used
>  to select the source address for any other packet originated by the
>  node, given the destination address of the packet."
>
> The door is left open for other address selection algorithms but, IMHO,
> changing kernel's behaviour is better justified by real use cases
> than by obsolete RFCs.

I agree, sorry for the obsoleted RFC. This is actually motivated by a
real use case: Say a Linux box is acting as a router that forwards
packets with policy routing from two local networks to two uplinks,
respectively. An outside host from is performing traceroute to a host on
one of the LAN. If the kernel's default route is via the other LAN's
uplink, it will send ICMPv6 packets with the source address that has
nothing to do with the network in question, yet the message probably
will reach the outside host.

Here using the address of inbound or exiting interface as source address
is evidently "a more informative choice." I surmise this is the reason
why the comment reads "Force OUTPUT device used as source address" when
dealing with hop limit exceeded packets in ip6_forward(), although not
effectively so. The current behaviour not only confuses diagnosis, but
also might be undesirable if the addresses of the networks are best kept
secret from each other.

Thanks,
Eli
