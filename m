From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET_SCHED] sch_api: fix qdisc_tree_decrease_qlen() loop
Date: Mon, 14 Apr 2008 15:11:02 -0700 (PDT)
Message-ID: <20080414.151102.169978802.davem@davemloft.net>
References: <20080413121031.GA5211@ami.dom.local>
	<20080414202605.GA6164@ami.dom.local>
	<4803BE84.4040105@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, enrico@superclick.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55663
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751381AbYDNWLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 18:11:01 -0400
In-Reply-To: <4803BE84.4040105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 14 Apr 2008 22:28:52 +0200

> Jarek Poplawski wrote:
> > [NET_SCHED] sch_api: fix qdisc_tree_decrease_qlen() loop
> >
> > TC_H_MAJ(parentid) for root classes is the same as for ingress, and if
> > ingress qdisc is created qdisc_lookup() returns its pointer (without
> > ingress NULL is returned). After this all qdisc_lookups give the same,
> > and we get endless loop. (I don't know how this could hide for so
> > long - it should trigger with every leaf class deleted if it's qdisc
> > isn't empty.)
> >
> > After this fix qdisc_lookup() is omitted both for ingress and root
> > parents, but looking for root is only wasting a little time here...
> > Many thanks to Enrico Demarin for finding a test for catching this
> > bug, which probably bothered quite a lot of admins.
> >   
> 
> Good catch, I agree that this is the reason for sure.

I'll take that as an ACK :-)

Applied, thanks everyone!
