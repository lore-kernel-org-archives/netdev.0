From: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when real-servers
 are removed
Date: Mon, 14 May 2007 16:25:18 +0200
Message-ID: <4648714E.9050200@tis.icnet.pl>
References: <200704271705.l3RH5Brw026873@hera.kernel.org>	<4648382E.8030009@trash.net> <20070514.033504.48528120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, horms@verge.net.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from d1.icnet.pl ([212.160.220.21]:48815 "EHLO d1.icnet.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754540AbXENOZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 10:25:27 -0400
In-Reply-To: <20070514.033504.48528120.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 14 May 2007 12:21:34 +0200
> 
>> This allows any user to send spoofed packets when ip_nonlocal_bind
>> is set, which is a quite big change in behaviour of this option.
>> The TPROXY patches include a similar change, but use a flag in
>> struct flowi that requires CAP_NET_ADMIN to be set, which seems like
>> a better idea. Alternatively you could just use input routing for
>> non-local source addresses like ip_route_me_harder does.
> 
> Good point.
> 
>> BTW, there doesn't even seem to be a spot where IPVS calls
>> ip_route_output with the source address set. What exactly is this
>> needed for?
> 
> I suppose he has a patch to make use of it, but was waiting
> for this route.c change to go in first.

If you mean me, the answer is no, I do not have any patch making use of 
the change in question. What I have is rather a complicated method of 
notifying udp clients on communication problems before they are 
redirected to a new real server. My method needs some IPVS related 
patches, but ICMP port unreachable messages are not generated inside 
IPVS code, they are just sent, with help of the patch in question, from 
udp_input() or netfilter REJECT.

It was my first intention to patch IPVS to send these messages, but I 
found no simple way to implement this in the current IPVS code.

Janusz

