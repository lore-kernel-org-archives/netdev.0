From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC] addition of a dropped packet notification service
Date: Wed, 25 Feb 2009 09:18:41 -0500
Message-ID: <20090225141841.GD16150@hmsreliant.think-freely.org>
References: <20090209102134.GA8492@gondor.apana.org.au> <20090224.234840.93952093.davem@davemloft.net> <20090225115419.GA16150@hmsreliant.think-freely.org> <20090225.040130.169376412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, shemminger@vyatta.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46490 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868AbZBYOS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 09:18:58 -0500
Content-Disposition: inline
In-Reply-To: <20090225.040130.169376412.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 25, 2009 at 04:01:30AM -0800, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed, 25 Feb 2009 06:54:19 -0500
> 
> > I had actually started down this road for awhile, and liked it for
> > its low maintenence overhead (as you mentioned, less to annotate),
> > but I balked at it after a bit, mostly for its increased ambiguity.
> > By catching the drop where the packet is freed, we lose information
> > about the exact point at which we decided to drop it.  As such,
> > users of said dumped table loose (or potentially lose) the ability
> > to correlate the saved stack pointer with an exact point in the code
> > where a corresponding statistic was incremented, as well as the
> > correlation to a specific point in the code (they just get the
> > calling function program counter rather than file, funciton and line
> > number).
> 
> Userland tools can extract this information from a non-stripped
> kernel image file, given just a kernel PC value.
> 
Sure, they can, but my origional post had this information captured at the drop
point (using __func__, __file__ and __LINE__).  My intent was that no debuginfo
package should be needed for a user to determine the point of the drop, just the
source tree (which can be consolidated to one location for multiple hosts, via
lxer, etc.), rather than installed on each individual machine.

Although as I think about it, theres no reason that a user space utility can't
use a symboled kernel to translate pc values if available, and do a reduced
symbol+offset translation using /proc/kallsyms in its absence.

> And you need the same thing to extract the same information
> if you used tracepoints.
> 
Well, I think the above implementation can be done with or without tracepoints.
The mechanism by which we get the drop information is orthogonal to what we do
with it.

Thanks for the feedback guys.  I'll start modifying my kernel changes to reflect
this striaght away.  If you'd like to see something in the interim, let me know
and I'll send you what I have.  Currently I've got the user space delivery
mechanism working as a Netlink protocol, and with your above suggestions, I
expect to have the drop capture piece recode and working in the next few weeks.

Best
Neil

