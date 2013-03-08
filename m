From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP small packets throughput and multiqueue virtio-net
Date: Fri, 08 Mar 2013 09:26:14 -0800
Message-ID: <513A1F36.5020401@hp.com>
References: <5139840A.6020204@redhat.com> <1362755115.15793.236.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, KVM <kvm@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jpirko@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:32687 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759940Ab3CHR0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 12:26:18 -0500
In-Reply-To: <1362755115.15793.236.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>
> Well, the point is : if your app does write(1024) bytes, thats probably
> because it wants small packets from the very beginning. (See the TCP
> PUSH flag ?)

I think that raises the question of whether or not Jason was setting the 
test-specific -D option on his TCP_STREAM tests, to have netperf make a 
setsockopt(TCP_NODELAY) call.

happy benchmarking,

rick jones

> If the transport is slow, TCP stack will automatically collapse several
> write into single skbs (assuming TSO or GSO is on), and you'll see big
> GSO packets with tcpdump [1]. So TCP will help you to get less overhead
> in this case.
>
> But if transport is fast, you'll see small packets, and thats good for
> latency.
>
> So my opinion is : its exactly behaving as expected.
>
> If you want bigger packets either :
> - Make the application doing big write()
> - Slow the vmexit ;)
>
> [1] GSO fools tcpdump : Actual packets sent to the wire are not 'big
> packets', but they hit dev_hard_start_xmit() as GSO packets.
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
