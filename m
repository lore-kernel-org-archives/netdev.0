From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when real-servers
 are removed
Date: Thu, 17 May 2007 18:40:28 +0200
Message-ID: <464C857C.9070406@trash.net>
References: <200704271705.l3RH5Brw026873@hera.kernel.org> <4648382E.8030009@trash.net> <20070514.033504.48528120.davem@davemloft.net> <4648714E.9050200@tis.icnet.pl> <464872E2.2030502@trash.net> <464884EE.3030606@tis.icnet.pl> <46489F5C.4000801@trash.net> <20070515052608.GG13708@verge.net.au> <4649DBB7.3070608@trash.net> <Pine.LNX.4.58.0705160012470.2626@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>,
	Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33449 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755263AbXEQQlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 12:41:09 -0400
In-Reply-To: <Pine.LNX.4.58.0705160012470.2626@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julian Anastasov wrote:
> 	 To summarize, what can help is a flag (eg. RT_ANYSRC) to
> ip_route_output* that all special users can provide to skip the
> check, for example:
> 	- RTCF_LOCAL packets in icmp_send() can avoid the check
> 	- NAT can avoid the check (ip_route_me_harder can be simplified?)


We want to be able to use iif in rules, so ip_route_me_harder still
needs to use ip_route_input().


> 	 Currently, all callers use the check, so may be the goal can be
> to start with small set of callers that can set the new flag. It looks
> like we can save some CPU cycles too, ip_route_me_harder looks too
> overloaded.
> 
> 
>>>I think that your patch looks good, assuming that inet_addr_type(VIP)
>>>is going to return RTN_LOCAL (except in the unlikely case that VIP is
>>>multicast or something silly like that.
>>
>>I'm not familiar with the IPVS terms, but as far as I understand,
>>it is _not_ going to return RTN_LOCAL, so we get the desired
>>behaviour of selecting a local address as source.
> 
> 
> 	But what is preferred is to use VIP in ICMP.
> 
> ip route add local VIP dev lo table user_defined
> 
> 	returns RTCF_LOCAL but inet_addr_type() does not return RTN_LOCAL,
> we fix one thing but break another :)


Actually thats exactly the case that my patch handles. Why does it
matter which source address the ICMP packet uses, as long as its
routed properly?

In any case some better solution than the current one needs to be
found, allowing users to send spoofed packets is far worse than
using a non-desired source address for ICMP packets.
