From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ip_no_pmtu_disc and UDP
Date: Mon, 26 Oct 2015 23:12:26 +0100
Message-ID: <1445897546.1785067.420905281.288C3AF1@webmail.messagingengine.com>
References: <CAK3+h2wFfh+HE78kHoWwgc9vyTCLWM90C4RQ=uTRk8551-jQ7A@mail.gmail.com>
 <1445639662.2872263.418778169.006CB827@webmail.messagingengine.com>
 <CAK3+h2y3AiN7byuw2ihBohbu+TmOs2ursBvvsL5rwd32MYDGYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:58742 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751789AbbJZWM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 18:12:28 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 31A73200FD
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 18:12:27 -0400 (EDT)
In-Reply-To: <CAK3+h2y3AiN7byuw2ihBohbu+TmOs2ursBvvsL5rwd32MYDGYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Mon, Oct 26, 2015, at 23:00, Vincent Li wrote:
> the UDP packet size is about 768, here is how packet path  like:
> 
> client
> <----------------------------------------router<-------------------------------------------------->server
> (eth0 mtu 1500 ip 10.3.72.69)     (eth0 mtu 1500 ip 10.3.72.1,
>           (eth0 mtu 1500 ip 10.2.72.99)
>                                                       eth1.1102 mtu
> 567 ip 10.2.72.139)
> 
> 
> UDP client test script:
> 
> [...]
> 
> so I am hoping if I echo 0, 1, 2, 3 respectively to
> /proc/sys/net/ipv4/ip_no_pmtu_disc, I am expected to see DF bit
> set/unset from the client and should have shown me on the router eth0
> interface tcpdump, but instead, DF bit never set on the client. am I
> misunderstanding something?

This is strange...

Can you please capture traffic on eth0 on the client?

For outgoing packets only zero or non-zero matter. A '0' definitely
generates a UDP packet with a DF bit on my side, anything else a frame
with DF bit cleared. I just verified this on net-next with your script.
It also does not cause any setsockopts but uses the default.

> for example:
> 
>  two concurrent tcpdump on router eth0 (mtu 1500) and eth1.1102 (mtu
> 576) interface:
> 
> 1 #tcpdump -nn -i eth0 -v udp and host 10.3.72.69 &
> 
> 14:51:11.946143 IP (tos 0x0, ttl 64, id 7193, offset 0, flags [none],
> proto UDP (17), length 796)
>     10.3.72.69.43748 > 10.2.72.99.9999: UDP, length 768
> 

As I said, I cannot reproduce that. :( Please test on eth0 directly so
we can be sure the packet does not get mangled.

Can you also show me the output of
ip route get 10.2.72.139
on the client after you maybe already received a icmp pkt-too-big
packet?

Thanks,
Hannes
