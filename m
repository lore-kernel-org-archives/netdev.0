From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Mon, 18 Jan 2010 17:47:11 -0500
Message-ID: <4B54E4EF.8080602@majjas.com>
References: <4B53906B.2020608@majjas.com> <20100117230531.GC3161@del.dom.local>
 <4B539A0A.2000504@majjas.com> <20100118073018.GA6270@ff.dom.local>
 <4B548C6B.10607@majjas.com> <20100118204658.GC3157@del.dom.local>
 <4B54CB0D.5070604@majjas.com> <20100118212516.GE3157@del.dom.local>
 <4B54D50C.90608@majjas.com> <20100118220814.GG3157@del.dom.local>
 <20100118221747.GH3157@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta4.srv.hcvlny.cv.net ([167.206.4.199]:62103 "EHLO
	mta4.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754878Ab0ARWrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 17:47:49 -0500
In-reply-to: <20100118221747.GH3157@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/18/2010 5:17 PM, Jarek Poplawski wrote:
> On Mon, Jan 18, 2010 at 11:08:14PM +0100, Jarek Poplawski wrote:
>    
>> Btw, I wonder if you could test it skipping the (HP?) switch?
>>      
> If so, then of course don't forget to try tcpdump on the router.
>
> Jarek P.
>    
Well - no.... but I'm not sure that would show anything.

Setup diagram:

Server->gb switch-> (100mb) wifi router -> devices
                     |
               Win7 PC (gb)

The problem does not occur (at least I haven't been able to recreate it) 
at 100mb, and the wifi router doesn't do 1Gb. I drive the traffic from 
the win7 PC to the server. I've seen the loss when the only traffic 
going through the wifi router was ping & dhcp. I've also never seen any 
loss on a device directly attached to the 1GB switch. I can drive load 
through the wifi router while driving load from the Win7 box, but don't 
see TX packet loss at all when not doing DHCP RELEASE/RENEW.

As there is no packet loss to devices not involved in the DHCP sequence 
through the same path, I'm not really sure that the GB switch is implicated.

As I don't have a standalone sniffer, I'm thinking that it might be 
easier to instrument places where the TX packet could be dropped and see 
at least whether it's getting to the card.

Given the circumstances of the TX drop, and that it was DHCP traffic 
while under load that caused the oops rectified with the two patches, 
I'm thinking that the packet loss is the current manifestation of 
whatever the underlying problem is. Given the extra hop required to 
break things, and given that a dhcp release/renew seems to trigger 
things, I keep coming back to arp logic as being somehow implicated.

If arp is somehow involved, then I'd expect to see manifestations under 
similar circumstances with other drivers. As the pskb_may_pull patch 
stopped the crash, perhaps other drivers do suffer packet loss and it's 
just not been widely noticed or attributed to the kernel - especially if 
the network topology is a factor. I do know people at large enterprises 
who have been complaining of what *could* be this same issue, however 
they're currently blaming their switch vendors. As most traffic is TCP, 
this is really only noticed by those few places deeply concerned with 
latency. It's likely something altogether different, but then again, 
maybe not.
