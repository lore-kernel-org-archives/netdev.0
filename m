From: Florian Westphal <fw@strlen.de>
Subject: Re: [WTF?] random test in netlink_sendmsg()
Date: Fri, 12 Dec 2014 23:20:21 +0100
Message-ID: <20141212222021.GC3624@breakpoint.cc>
References: <20141128062315.GC29748@ZenIV.linux.org.uk>
 <20141212.153433.1675057029307550538.davem@davemloft.net>
 <20141212213242.GE22149@ZenIV.linux.org.uk>
 <20141212215017.GB3624@breakpoint.cc>
 <20141212221410.GF22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:35047 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751224AbaLLWU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 17:20:27 -0500
Content-Disposition: inline
In-Reply-To: <20141212221410.GF22149@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro <viro@ZenIV.linux.org.uk> wrote:
> On Fri, Dec 12, 2014 at 10:50:17PM +0100, Florian Westphal wrote:
> 
> > > What do we want sendmsg(fd, &msg, 0) to do when fd is AF_NETLINK socket
> > > that had setsockopt(fd, SOL_NETLINK, NETLINK_TX_RING, ...) successfully done
> > > to it and msg.msg_iovlen is 0?  Userland ABI question
> > 
> > IIRC userland, after filling txring with at least one new netlink
> > message, needs to call this to tell kernel to start processing the
> > messages in the tx ring.
> 
> AFAICS, the suggested way to initiate transmission is sendto(fd, NULL, 0, ...),
> not sendmsg(2).

Indeed, you're right.
