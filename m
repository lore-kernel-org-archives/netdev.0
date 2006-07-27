From: David Miller <davem@davemloft.net>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Wed, 26 Jul 2006 23:00:28 -0700 (PDT)
Message-ID: <20060726.230028.00077989.davem@davemloft.net>
References: <1153966671.6904.71.camel@localhost.localdomain>
	<20060726.221708.123400049.davem@davemloft.net>
	<1153979173.6904.100.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22236
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932436AbWG0GAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 02:00:09 -0400
To: rusty@rustcorp.com.au
In-Reply-To: <1153979173.6904.100.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 27 Jul 2006 15:46:12 +1000

> Yes, my first thought back in January was how netfilter would interact
> with this in a sane way.  One answer is "don't": once someone registers
> on any hook we go into slow path.  Another is to run the hooks in socket
> context, which is better, but precludes having the consumer in
> userspace, which still appeals to me 8)

Small steps, small steps.  I have not ruled out userspace TCP just
yet, but we are not prepared to go there right now anyways.  It is
just the same kind of jump to go to kernel level netchannels as it is
to go from kernel level netchannels to userspace netchannel based TCP.

> What would the tuple look like?  Off the top of my head:
> SRCIP/DSTIP/PROTO/SPT/DPT/IN/OUT (where IN and OUT are boolean values
> indicating whether the src/dest is local).
> 
> Of course, it means rewriting all the userspace tools, documentation,
> and creating a complete new infrastructure for connection tracking and
> NAT, but if that's what's required, then so be it.

I think we are able to finally talk seriously about revamping
netfilter on this level because we finally have a good incentive to do
so and some kind of model exists to work against.  Robert's trie might
be able to handle your tuple very well, fwiw, perhaps even with
prefixing.

But something occurs to me.  Socket has ID when it is created and
goes to established state.  This means we have this tuple, and thus
we can prelookup the netfilter rule and attach this cached lookup
state on the socket.  Your tuple in this case is defined to be:

	SRCIP/DSTIP/"TCP"/SPT/DPT/0/1

I do not know how practical this is, it is just some suggestion.

Would there be prefixing in these tuples?  That's where the trouble
starts.  If you add prefixing, troubles and limitations of lookup of
today reappear.  If you disallow prefixing, tables get very large
but lookup becomes simpler and practical.
