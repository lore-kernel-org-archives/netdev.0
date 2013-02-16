From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH net-next (V2)] ipv6: Queue fragments per interface
 for multicast/link-local addresses.
Date: Sat, 16 Feb 2013 13:53:27 -0500
Message-ID: <511FD5A7.3050207@redhat.com>
References: <511F1E03.9010205@linux-ipv6.org>  <1360995918.19353.56.camel@edumazet-glaptop>  <511F6FF1.9000004@linux-ipv6.org> <1361031313.19353.63.camel@edumazet-glaptop>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, davem@davemloft.net,
	Ben Greear <greearb@candelatech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22849 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753968Ab3BPSxf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 13:53:35 -0500
In-Reply-To: <1361031313.19353.63.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/16/2013 11:15 AM, Eric Dumazet wrote:
> On Sat, 2013-02-16 at 20:39 +0900, YOSHIFUJI Hideaki wrote:
>
>> Could you elaborate, please?
>>
>> The patch does not compare incoming interface if address is
>> non-link-local unicast address.
>
> There must be a reason ipv6 reasm is duplicated in
> net/ipv6/netfilter/nf_conntrack_reasm.c
>
> netfilter uses the notion of ct zone, and several nics can belong to
> same zone.
>
> Anyway your patch touches netfilter land, so must be CC to netfilter
> guys.
>
> M:      Pablo Neira Ayuso <pablo@netfilter.org>
> M:      Patrick McHardy <kaber@trash.net>
> L:      netfilter-devel@vger.kernel.org
>

Looks like netfilter implementation will benefit from a similar patch as 
well.  I like the idea of tagging the reassembly queue with the 
interface and I think it would have application in netfilter as well.
Link-local traffic is limited to the interface already, so that 
shouldn't break netfilter assumptions.  Multicast traffic is also bound
to an interface since group membership is per interface.  If multiple 
interfaces are receiving the same fragmented multicast traffic, we want
multiple reassembly queues, or we'd end up discarding.

-vlad
