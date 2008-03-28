From: Julian Anastasov <ja@ssi.bg>
Subject: ICMP host relookup support doubts
Date: Fri, 28 Mar 2008 10:51:32 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0803281002210.3562@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:54491 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751821AbYC1I7G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 04:59:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

	Am I missing something but it seems recent code (12 Dec 2007)
in icmp_send uses fl.fl4_src for output and input routes while it can
be initialized with saddr = 0 for non-local address. While this was
suited for the initial output route to avoid error for non-local
saddr, I suspect the relookup support uses it for additional output
and input route. Isn't the end result that no ICMP error is sent
after ip_route_input error for saddr=0? I assume no ICMP is generated
for forwarded traffic, expect if xfrm_lookup changes fl somewhere.
May be someone should fix it by replacing fl.fl4_src usage in the
new code with original iph->daddr? Eg. fl2.fl4_dst and the saddr arg
for ip_route_input? I don't know what is right to be done here.
saddr=0 should be used only as saddr arg to output route. OTOH, 
sysctl_icmp_errors_use_inbound_ifaddr can change the saddr too.

Regards

--
Julian Anastasov <ja@ssi.bg>
