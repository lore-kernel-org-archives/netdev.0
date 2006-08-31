From: David Miller <davem@davemloft.net>
Subject: Re: high latency with TCP connections
Date: Thu, 31 Aug 2006 15:44:28 -0700 (PDT)
Message-ID: <20060831.154428.35684218.davem@davemloft.net>
References: <20060830102727.11e11453@localhost.localdomain>
	<20060831214635.GA2680@ms2.inr.ac.ru>
	<20060831151456.12a4e080@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6306
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932465AbWHaWoX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 18:44:23 -0400
To: shemminger@osdl.org
In-Reply-To: <20060831151456.12a4e080@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 31 Aug 2006 15:14:56 -0700

> On Fri, 1 Sep 2006 01:46:35 +0400
> Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:
> 
> > > Expecting any performance with one byte write's is silly.
> > 
> > I am not sure why you are so confident about status of ABC.
> > I missed the discussions, when it was implemented. Apparently,
> > it was noticed that ABC in its pure form does not make sense
> > with snd_cwnd counted in packets and there were some reasons,
> > why it still was not adapted.
> 
> I implemented it but don't think ABC is the correct thing to be doing
> in all cases.
> 
> If you read the RFC3465, the problem it is trying to address is that of
> small packets causing growth of congestion window beyond the capacity
> of the link.
> 
> It makes a number of assumptions that may not be true for Linux:
>   * ABC doesn't take into account congestion window validation RFC2861
>     already prevents most of the problem of inflated growth.
>   * ABC assumes that the "true" capacity of the link is limited by
>     byte count not packet count.

It seems to me that the thing gained by ABC are twofold:

1) protection against ACK division
2) a way to take delayed ACKs into account for cwnd growth

Both of which can be obtained by simply validating the ACK
against the retransmit queue, returning number of true
packets ACK'd.

I would even go so far as to suggest that we should drop ACKs which do
not fall on packetization boundaries.  Perhaps only when not in LOSS
state, but I doubt that this matters in practice.

Cases where mid-packet ACK is valid are truly marginal ones involving
repacketization wrt. MSS/MTU changes, and these would self-correct
eventually.

I agree that ABC has some problems.  Solution is good, implementation
is just horrible :-)
