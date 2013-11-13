From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] netlink: fix netlink_ack with large messages
Date: Wed, 13 Nov 2013 12:25:04 +0100
Message-ID: <20131113122504.0ddcbf89@griffin>
References: <527E3C17.1080508@mojatatu.com>
	<20131109180353.GA3715@localhost>
	<20131112162907.50f0bafa@griffin>
	<20131112.143515.1092879587357986857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, jhs@mojatatu.com, tgraf@suug.ch,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28627 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756816Ab3KMLZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 06:25:37 -0500
In-Reply-To: <20131112.143515.1092879587357986857.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Nov 2013 14:35:15 -0500 (EST), David Miller wrote:
> > Do you think capping at NLMSG_GOODSIZE would be too low? The allocation
> > won't fit into one page with NLMSG_GOODSIZE but I doubt we can go lower
> > than that. Alternatively, we can do some math to fully use the two
> > pages, like
> > 	NLMSG_GOODSIZE + min(PAGE_SIZE, 8192UL) - NLMSG_HDRLEN - NLMSG_ALIGN(sizeof(struct nlmsgerr))
> > (which I'm not sure is worth it).
> 
> I don't think this is the way to go.
> 
> I think since existing apps expect the whole message, we have to
> provide it.
> 
> We should add a new socket option so that applications can ask that
> messages not be quoted in ACKs, as I've stated a few times already in
> this thread.

I completely agree with this, sorry for not being clear. I just
understood from the thread that the way to go is to do both, in order
to not generate too large ACKs for the _new_ code (i.e. for the
messages that were not plausible before "netlink: allow large data
transfers from user-space"). I don't know what the "too large" should
be, though, hence the question.

But then, if we don't do any capping, the only outcome of a failed
allocation is the ACK won't be sent and it's clearly stated that
netlink does not provide reliability. Works for me.

 Jiri

-- 
Jiri Benc
