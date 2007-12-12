From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] iproute2: support dotted-quad netmask notation.
Date: Wed, 12 Dec 2007 08:40:33 -0800
Message-ID: <20071212084033.0efb24e7@freepuppy.rosehill>
References: <20071204135818.GA24419@scream.fatal.se>
	<20071206115350.18e9204f@freepuppy.rosehill>
	<1197070894.5385.14.camel@localhost.localdomain>
	<1197220222.4392.9.camel@localhost.localdomain>
	<20071211171406.57389dba@freepuppy.rosehill>
	<20071212115513.GA3394@scream.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34821 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757020AbXLLQmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 11:42:02 -0500
In-Reply-To: <20071212115513.GA3394@scream.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2007 12:55:13 +0100
Andreas Henriksson <andreas@fatal.se> wrote:

> On Tue, Dec 11, 2007 at 05:14:06PM -0800, Stephen Hemminger wrote:
> > On Sun, 09 Dec 2007 18:10:22 +0100
> > Andreas Henriksson <andreas@fatal.se> wrote:
> > > I think both previous patches where broken on big-endian platforms.
> > > Here's an updated patch again. I'm very sorry for the inconvenience!
> [...]
> > > +		*val=0;
> > > +		for (mask = ntohl(addr.data[0]); mask; mask <<= 1)
> > > +			(*val)++;
> [...]
> > 
> > applied
> > 
> 
> Just to make sure.... It looks on git.kernel.org like you applied the wrong
> patch. (Maybe you just haven't pushed out the latest changes there yet.)
> Please double-check that you actually applied the latest version (which is
> the one in the mail you replied "applied" to, important part quoted above). 

Actually, I took your logic and moved it to a new function:

static unsigned cidr(const inet_prefix *addr)
{
	unsigned bits = 0;
	u_int32_t mask;

	for (mask = ntohl(addr->data[0]); mask; mask <<= 1)
		++bits;

	return bits;
}
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
