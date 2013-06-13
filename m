From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: skb_is_gso() in ip_forward.c
Date: Thu, 13 Jun 2013 17:57:25 +0100
Message-ID: <1371142645.2246.6.camel@bwh-desktop.uk.level5networks.com>
References: <CAF0Lin26AEdtz+Ui=LQ-T285OpbgfnsN3ofdmvbwavM9eQjBCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Andy Johnson <johnsonzjo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8598 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751603Ab3FMQ52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 12:57:28 -0400
In-Reply-To: <CAF0Lin26AEdtz+Ui=LQ-T285OpbgfnsN3ofdmvbwavM9eQjBCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-12 at 16:48 +0300, Andy Johnson wrote:
> Hi,
> 
> I would appreciate if someone can explain the following :
> 
> We have this in net/ipv4/ip_forward():
> ...
>  if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
>   ...
>   icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
>                             htonl(dst_mtu(&rt->dst)));
>                   goto drop;
>           }
> ...
> 
> As I understand, it the traffic is GSO and the length of the skb is
> larger than the MTU, we don't send destination unreachable ICMP and
> we continue with forwarding the packet. My qustion is: why is it so ?
> is it because when working with GSO the size of skb->len is not the
> size of the packet which is sent on the wire ?

Right.

> The what does it represent when the traffic is GSO ?

Length of all data in the skb, which is the length of the headers for a
single packet plus the total length of the payload.

Ben.

> I would appreaicate if someone can elaborate on this.


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
