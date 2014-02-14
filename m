From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] bonding: 802.3ad: make aggregator_identifier bond-private
Date: Fri, 14 Feb 2014 19:48:37 -0200
Message-ID: <20140214214837.GB3173@localhost.localdomain>
References: <20140214171350.GC11688@midget.suse.cz>
 <20140214191243.GA3173@localhost.localdomain>
 <20140214205147.GA1798@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4125 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752774AbaBNVuI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 16:50:08 -0500
Content-Disposition: inline
In-Reply-To: <20140214205147.GA1798@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 09:51:47PM +0100, Jiri Bohac wrote:
> On Fri, Feb 14, 2014 at 05:12:43PM -0200, Flavio Leitner wrote:
> > On Fri, Feb 14, 2014 at 06:13:50PM +0100, Jiri Bohac wrote:
> > > Fix this by making aggregator_identifier private to the bond.
> > 
> > I don't see how you fix the duplicate agg id with this patch because
> > you initialize for each bond to 0, then use the same algo further on.
> > So, what is changing?
> 
> My understanding is that the aggregator identifier is used
> internally by the bond and never appears anywhere in the LACP
> traffic.
> 
> So having duplicate aggregator ids between two bonds on the same
> machine does not matter. But it is a problem if two aggregators
> in the same bond share the same id.
> 
> Is my understanding wrong?

No, I agree that having two agg id in the same bond is a problem
while we can have the same agg id in different bonds.

> > Actually, aggregator_identifier is a global variable to make sure the
> > counter is always increasing for new bonds.  So, the fix would be to
> > not reset it to zero, isn't it?
> 
> I was considering this fix, but my concern was that the variable
> (u16) would overflow sooner than it does now. It would take 2^16
> enslavings on the machine, while with my patch you need 2^16
> enslavings on a single bond.
> 
> Hypothetically, a rogue NET_ADMIN in one net namespace may cause
> this overflow to break a bond in another nemespace.

Well, I think it is easier to troubleshoot if you have one agg id
regardless of bonding. Also, the id is visible in /proc and I
recall to have seen a script using it somehow, but yeah you made a
good point.
 
> Maybe I'm being paranoid? ;)

I will defer to bonding maintainer to decide. :P

Thanks,
fbl
