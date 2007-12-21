From: Glen Turner <gdt@gdt.id.au>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Fri, 21 Dec 2007 15:21:26 +1030
Message-ID: <1198212686.5904.17.camel@andromache>
References: <83a51e120712141239u52d2dd68p1b6ee7ed08f2cecf@mail.gmail.com>
	 <83a51e120712181021p4c4c2a13g8820271f1e00361b@mail.gmail.com>
	 <4768123A.7040603@cosmosbay.com>
	 <83a51e120712181144l65633b32r72cc369f9d012f47@mail.gmail.com>
	 <47682F8C.20205@cosmosbay.com>
	 <83a51e120712190853q33d9c7c1t4a46380665b7538b@mail.gmail.com>
	 <47694FCC.1020507@cosmosbay.com>
	 <83a51e120712190943m3bf0e2e4v2ea6b660142e9a5a@mail.gmail.com>
	 <Pine.LNX.4.64.0712191857270.12329@fbirervta.pbzchgretzou.qr>
	 <1198161695.6154.47.camel@andromache>
	 <83a51e120712200837p9e3d1a4g15b5f4763597073e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@computergmbh.de>,
	Eric Dumazet <dada1@cosmosbay.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Nichols <jamesnichols3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:60336 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752813AbXLUE6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:58:45 -0500
In-Reply-To: <83a51e120712200837p9e3d1a4g15b5f4763597073e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I do have TCP Sequence # Randomization enabled on my router.

Huh?  Do you mean a PIX blade in a Cisco switch-router chassis? It
would be very useful if you could be less vague about the
equipment in use.

>  However,
> if this was causing an issue, wouldn't it always occur and cause
> connection issues, not just after 38 hours of correct operation?

That depends more on your customers' networking attributes
then you are sharing or perhaps even know.  Perhaps your customer
base is very Window-skewed and you simply aren't seeing any Sack
Permitted negotiations for the first 37.999 hours. Or
perhaps you've had a network glitch, and all of your
connections have done a Selective Ack, which the firewall
has trashed, leaving all the connections in a wacko state,
not just a few which you haven't noticed.

The actual failure mode needs a packet trace to determine,
but you should be able to do this yourself (or ask your
local network engineering staff).

If your firewall is trashing the Sack field, then it needs
to be fixed.  Time to raise a case with the Cisco TAC and
ask them directly if your PIX version has bug CSCse14419.
You can't expect Sack to work when it's being fed trash,
so it is important to make sure that is not happening.

Cheers, Glen
#include <network_engineer.h>
#undef KERNEL_HACKER

