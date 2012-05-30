From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 0/2] Faster/parallel SYN handling to mitigate SYN
 floods
Date: Thu, 31 May 2012 00:40:30 +0200
Message-ID: <1338417630.7747.156.camel@localhost>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
	 <4FC3A465.4030203@uclouvain.be> <1338322661.7747.17.camel@localhost>
	 <4FC53353.2050801@uclouvain.be> <1338367497.7747.72.camel@localhost>
	 <4FC5DFF4.1020604@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	opurdila@ixiacom.com,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Andi Kleen <andi@firstfloor.org>
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16696 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757053Ab2E3Wkz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2012 18:40:55 -0400
In-Reply-To: <4FC5DFF4.1020604@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 10:53 +0200, Christoph Paasch wrote:
> On 05/30/2012 10:44 AM, Jesper Dangaard Brouer wrote:
> >> > 
> >> > Then the receiver will receive two SYN/ACK's for the same SYN with
> >> > different sequence-numbers. As the "SYN cookie SYN-ACK" will arrive
> >> > second, it will be discarded and seq-numbers from the first one will be
> >> > taken on the client-side.
> > I thought that the retransmitted SYN packet, were caused by the SYN-ACK
> > didn't reach the client?
> 
> Or, if the SYN/ACK got somehow delayed in the network and the
> SYN-retransmission timer on the client-side fires before the SYN/ACK
> reaches the client.

That seems like a very unlikely situation, which we perhaps should
neglect as we are under SYN attack.

I will test the attack vector, if we instead of dropping the reqsk, fall
back into the slow locked path.
