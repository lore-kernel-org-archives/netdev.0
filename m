From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v3] ipv6: mld: fix add_grhead skb_over_panic for devs
 with large MTUs
Date: Wed, 05 Nov 2014 17:38:03 +0100
Message-ID: <1415205483.3264462.187432293.00A1F284@webmail.messagingengine.com>
References: <1415198530-7126-1-git-send-email-dborkman@redhat.com>
 <1415204413.13896.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, lw1a2.jing@gmail.com, fw@strlen.de,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	David L Stevens <david.stevens@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:40046 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932239AbaKEQiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 11:38:04 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 46CD8205F6
	for <netdev@vger.kernel.org>; Wed,  5 Nov 2014 11:38:04 -0500 (EST)
In-Reply-To: <1415204413.13896.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 5, 2014, at 17:20, Eric Dumazet wrote:
> On Wed, 2014-11-05 at 15:42 +0100, Daniel Borkmann wrote:
> > It has been reported that generating an MLD listener report on
> > devices with large MTUs (e.g. 9000) and a high number of IPv6
> > addresses can trigger a skb_over_panic():
> 
> ...
> 
> >  v2->v3:
> >   - Still had a discussion w/ Hannes and improved the code a bit to
> >     make it more clear to read
> 
> I am very sorry Daniel, but I found v2 much easier to understand :(
> 
> Could you refrain from doing cleanups in this patch,
> only provide the very minimal fix ?
> 
> No empty lines additions or deletions and stuff like that...
> 
> Then, we can cleanup for net-next later if you really want ;)
> 
> I know its _very_ tempting to do cleanups, but its very time consuming
> to review patches having real stuff done (like bug fixes) and cleanups.

My point was that the max_t(int, ..., ...) assignment to
reserved_tailroom was too implicit in case we allocated an skb smaller
than the mtu and reserved_tailroom should become '0'.

I would still vote for this version, but see the problem with the noise
caused by newline updates. Eric, would you mind a new version with only
the essential parts changed and keeping this calculation so we don't
need to change it twice for net and for net-next?

Bye,
Hannes
