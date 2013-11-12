From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] netlink: fix netlink_ack with large messages
Date: Tue, 12 Nov 2013 16:29:07 +0100
Message-ID: <20131112162907.50f0bafa@griffin>
References: <9333f540a9b87adbdd15e274d12a9d60994fdb34.1383850578.git.jbenc@redhat.com>
	<20131108.150741.966018155704146843.davem@davemloft.net>
	<20131109000434.GD28793@casper.infradead.org>
	<20131109.000012.1393414533296613338.davem@davemloft.net>
	<527E3C17.1080508@mojatatu.com>
	<20131109180353.GA3715@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57023 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752905Ab3KLP3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Nov 2013 10:29:41 -0500
In-Reply-To: <20131109180353.GA3715@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 9 Nov 2013 19:03:53 +0100, Pablo Neira Ayuso wrote:
> On Sat, Nov 09, 2013 at 08:43:51AM -0500, Jamal Hadi Salim wrote:
> > for errors, we need to give the user something back. This has been the
> > behavior for 80 years now. Giving them a HUGE message
> > back is rediculuos(tm). Ive had enough of SCTP doing that.
> > We need to cap it - sort of what ICMP does.
> > ICMP caps at 64B; something like 128B is reasonable.
> 
> Personally, I have only used the sequence number to correlate the
> original request with the ack reply, so I agree in that trimming it to
> some reasonable amount of bytes like ICMP is the way to go. I prefer
> if we select a large enough amount of bytes to avoid breaking backward
> compatibility, eg. 128KB, since I'm not sure what kind of handling
> others may have done of this.

Do you think capping at NLMSG_GOODSIZE would be too low? The allocation
won't fit into one page with NLMSG_GOODSIZE but I doubt we can go lower
than that. Alternatively, we can do some math to fully use the two
pages, like
	NLMSG_GOODSIZE + min(PAGE_SIZE, 8192UL) - NLMSG_HDRLEN - NLMSG_ALIGN(sizeof(struct nlmsgerr))
(which I'm not sure is worth it).

 Jiri

-- 
Jiri Benc
