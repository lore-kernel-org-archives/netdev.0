From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH RFC] libnetlink: introduce DECLARE_NLREQ
Date: Thu, 26 Nov 2015 15:00:01 +0100
Message-ID: <20151126140001.GA14223@orbit.nwl.cc>
References: <1448544365-23153-1-git-send-email-phil@nwl.cc>
 <87oaegx3sh.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:48635 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751274AbbKZOAE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Nov 2015 09:00:04 -0500
Content-Disposition: inline
In-Reply-To: <87oaegx3sh.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 26, 2015 at 02:56:30PM +0100, Hannes Frederic Sowa wrote:
> > +#define DECLARE_NLREQ(name, hdrname, payload, tailroom)                       \
> > +	struct {                                                              \
> > +		struct nlmsghdr hdrname;                                      \
> > +		payload;                                                      \
> > +		char __b[tailroom] __attribute__((aligned(NLMSG_ALIGNTO)));   \
> > +	} name = { .hdrname = {                                               \
> > +		.nlmsg_len = (unsigned long)&name.__b - (unsigned long)&name, \
> 
> offsetof(typeof(name), __b) ?

Ah, thanks! I already considered offsetof(), but the fact it needs a
type name and the declared struct is anonymous appeared unsolvable to
me. Good to know typeof() can be used this way!

Thanks, Phil
