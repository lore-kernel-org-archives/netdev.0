From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [net-next-2.6 PATCH 1/7] xfrm: introduce basic mark infrastructure
Date: Tue, 16 Feb 2010 13:59:41 +0100
Message-ID: <m3hbphxrnm.fsf@ursa.amorsen.dk>
References: <1266160732-946-1-git-send-email-hadi@cyberus.ca>
	<1266160732-946-2-git-send-email-hadi@cyberus.ca>
	<4B796B70.2050102@trash.net> <1266253235.6776.90.camel@bigi>
	<4B797F09.5050207@trash.net> <1266254073.6776.109.camel@bigi>
	<m37hqdcvgm.fsf@ursa.amorsen.dk> <1266321437.6776.250.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, timo.teras@iki.fi,
	herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:48080 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755635Ab0BPM74 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 07:59:56 -0500
In-Reply-To: <1266321437.6776.250.camel@bigi> (jamal's message of "Tue, 16 Feb
	2010 06:57:17 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal <hadi@cyberus.ca> writes:

> With these patches if you set policy routing mark, have the proper
> setting in the skb or socket for the mark then the proper
> route will be selected. If you have an SPD + SA added with the
> same mark, those will be used right after the route is selected. 
> So essentially you have the same mark across.
> Does that solve or alleviate the problem?

I don't actually use marks at all, I do policy routing based on source
address. Currently rules are based on source interface, but all IPSEC
traffic comes from the same interface, unlike some tunnel-based
solutions.

Right now packets going out through an IPSEC tunnel do not hit the
routing table at all -- they just get shunted into the tunnel. Anything
that gives me the chance to run the packets through normal routing
before the tunnel grabs them works for me.

>From your description, I would add the IPSEC SPD + SA with a specific
mark. Then I would set the mark in the rule table if I want the packets
to go through the tunnel, or clear the mark to have them go through
normal routing. Not perfect, because I would have to replicate parts of
the routing table in the rule table, but it could be made to work.

Perfect would be if I could set mark in the routing table instead of the
rule table, but sometimes perfect is the enemy of good...


/Benny

