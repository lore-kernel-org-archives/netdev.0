From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCHv3] ipv6: Enable enough of the code to handle GSO when
 disabled.
Date: Wed, 17 Oct 2012 15:11:45 -0400
Message-ID: <507F02F1.5010501@redhat.com>
References: <1350488802-24071-1-git-send-email-vyasevic@redhat.com> <1350490397.26103.647.camel@edumazet-glaptop>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24373 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755898Ab2JQTLs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2012 15:11:48 -0400
In-Reply-To: <1350490397.26103.647.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2012 12:13 PM, Eric Dumazet wrote:
> On Wed, 2012-10-17 at 11:46 -0400, Vlad Yasevich wrote:
>
>> This patch attempts to solve this by enabling just enough code so GSO
>> is correctly processed.  However, I should point out that if IPv6 is
>> simply blacklisted or not built for the kernel, this problem will
>> still persist.
>
> So I guess this should be done in a different way ?
>
> We currently use a single structure (struct packet_type) to hold
> pointers to different methods. (The .func() field, and the gso/gro
> stuff)
>
> We probably need to split it in two parts, and make one part linked into
> kernel, even if CONFIG_IPV6=n, so that GRO/GSO is fully IPv4/IPv6
> functional.

The thing about this approach is that if there are any other protocols 
that could have to provide their own segmentation functionality, such 
functionality would always have to be part of the kernel.  I wasn't sure 
how much I liked that.

>
> By the way, do we really need a hash table for this ?
> It seems we only have IPv4 (ETH_P_IP) and IPv6 (ETH_P_IPV6) to take care
> of ?

Which hash are you talking about?  I didn't add any hashes.

>
> This would remove some tests we currently have in GRO stack, and some
> RCU stuff as well.
> (GRO is slower if we have many af_packet sockets)
>
> list_for_each_entry_rcu(ptype, head, list) {
>      if (ptype->type != type || ptype->dev || !ptype->gro_receive)
>          continue;
> ...
>
> Adding a hook/test in ipv6_rcv() is ugly.
>

There already is one for device.  I original had a stub ipv6_rcv that 
just dropped the packet.  I could resurrect that if that's better...

-vlad

>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
