From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: DSCP values in TCP handshake
Date: Tue, 19 Apr 2011 06:28:02 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1104190620070.14027@uplift.swm.pp.se>
References: <loom.20110418T154445-102@post.gmane.org> <1303135512.3137.335.camel@edumazet-laptop> <20110418083827.05dd2d43@nehalam> <alpine.DEB.2.00.1104181750150.14027@uplift.swm.pp.se> <4DAC8A8A.1010401@cox.net> <alpine.DEB.2.00.1104182115291.14027@uplift.swm.pp.se>
 <20110418144908.55967b06@nehalam> <alpine.DEB.2.00.1104190547300.14027@uplift.swm.pp.se> <20110418211637.57f1cfb8@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Joe Buehler <aspam@cox.net>, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:47613 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750958Ab1DSE2E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 00:28:04 -0400
In-Reply-To: <20110418211637.57f1cfb8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Apr 2011, Stephen Hemminger wrote:

> Linux does not look at DSCP of incoming packets (there is no queue).

Then I see no reason for the policy of not reflecting DSCP.

If we receive the DSCP marked packet then it means the network is either 
not QoS enabled (it doesn't care) or it's actually allowed through the 
border router with DSCP unchanged. Either means it's safe to reflect the 
DSCP value, either it will have no effect or it's actually meant to be 
prioritized.

With precedence, it originally was mandated that if the precedence value 
changed, the TCP session should be reset. Fortunately, this was changed 
but I would still say that it's thought that DSCP values should be 
reflected by the server.

For instance:

<http://tools.ietf.org/html/draft-ietf-ieprep-reflexive-dscp-02>

"The requester could initiate this. Thus, if the DSCP
    received on one TCP segment differs from the TCP used on a prior TCP
    segment in a session, the new DSCP SHOULD be reflected unless local
    policy prevents this."

I don't know why this didn't make it into RFC, I can inquiry if there is 
interest.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
