From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when
 real-servers are removed
Date: Fri, 18 May 2007 11:40:54 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0705181043390.2665@u.domain.uli>
References: <200704271705.l3RH5Brw026873@hera.kernel.org> <4648382E.8030009@trash.net>
 <20070514.033504.48528120.davem@davemloft.net> <4648714E.9050200@tis.icnet.pl>
 <464872E2.2030502@trash.net> <464884EE.3030606@tis.icnet.pl>
 <46489F5C.4000801@trash.net> <20070515052608.GG13708@verge.net.au>
 <4649DBB7.3070608@trash.net> <Pine.LNX.4.58.0705160012470.2626@u.domain.uli>
 <464C857C.9070406@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Simon Horman <horms@verge.net.au>,
	Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:1499 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754297AbXERIlv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 May 2007 04:41:51 -0400
In-Reply-To: <464C857C.9070406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 17 May 2007, Patrick McHardy wrote:

> > 	But what is preferred is to use VIP in ICMP.
> > 
> > ip route add local VIP dev lo table user_defined
> > 
> > 	returns RTCF_LOCAL but inet_addr_type() does not return RTN_LOCAL,
> > we fix one thing but break another :)
> 
> 
> Actually thats exactly the case that my patch handles. Why does it
> matter which source address the ICMP packet uses, as long as its
> routed properly?

	It should work for most of the cases but it can cause problems
in closely connected hosts where using the right subnet matters.
If inet_addr_type is not considered slow for routers and this
local route justifies it then i have no more objections. May be
Janusz should test it first without sysctl_ip_nonlocal_bind change.

> In any case some better solution than the current one needs to be
> found, allowing users to send spoofed packets is far worse than
> using a non-desired source address for ICMP packets.

	yes, I would prefer the sysctl_ip_nonlocal_bind change to be
removed until such solution is found.

Regards

--
Julian Anastasov <ja@ssi.bg>
