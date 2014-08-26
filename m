From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Aw: Re: Routes with unreachable gateways are staying in the
 routing table and they are functional
Date: Tue, 26 Aug 2014 14:34:57 +0200
Message-ID: <1409056497.9923.9.camel@localhost>
References: <trinity-f1954363-c4ef-47d2-9508-7174b7e2501e-1408720289787@3capp-gmx-bs15>
	, <alpine.LFD.2.11.1408221856210.7852@ja.home.ssi.bg>
	 <trinity-760989cf-0ea4-496a-9992-02ed85a5ffe5-1409039594977@3capp-gmx-bs38>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org
To: Fedor Babkin <fedor.babkin@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:53387 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751006AbaHZMfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 08:35:00 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id D4A38206FB
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 08:34:59 -0400 (EDT)
In-Reply-To: <trinity-760989cf-0ea4-496a-9992-02ed85a5ffe5-1409039594977@3capp-gmx-bs38>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Di, 2014-08-26 at 09:53 +0200, Fedor Babkin wrote:
> Thanks for your feedback. For IPv4 the situation is clear, you have to configure more that one subnet to the interface in order to start experiencing this issue. However exactly the same issue exists in IPv6, where once you configure a single address, you have to count on effectively having 2 addresses on the interface, due to the presence of a link-local address fe80::xxxx. Moreover with IPv6 stateless address autoconfiguration (RFC 4862), there is more address configuration dynamics in IPv6 comparing to IPv4. I would say this issue has a higher visibility and side-effect potential. Is there anyone looking into this issue from IPv6 perspective?

Actually, it is an error and an implementation problem that we currently
add interface routes when adding ipv6 addresses to an interface. Those
routes should only be allocated when the host receives on-link
information (redirect, router advertisment). So in case of IPv6 routing
information should always be handled separate from routing information.

Also see:
$ git log -G IFA_F_NOPREFIXROUTE net/ipv6/addrconf.c

Greetings,
Hannes
