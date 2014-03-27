From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Thu, 27 Mar 2014 09:43:07 -0400
Message-ID: <20140327134307.GB31168@tuxdriver.com>
References: <532C2AC4.7080303@mojatatu.com>
 <20140322094852.GB2844@minipsycho.orion>
 <5330BAB7.3040501@mojatatu.com>
 <20140325173927.GE8102@hmsreliant.think-freely.org>
 <20140325180009.GB15723@casper.infradead.org>
 <20140325193533.GF8102@hmsreliant.think-freely.org>
 <5331ED86.7020704@mojatatu.com>
 <20140326111031.GB31370@hmsreliant.think-freely.org>
 <20140326112903.GG15723@casper.infradead.org>
 <20140326182122.GC31370@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, Jamal Hadi Salim <jhs@mojatatu.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53172 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbaC0Npu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 09:45:50 -0400
Content-Disposition: inline
In-Reply-To: <20140326182122.GC31370@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 02:21:22PM -0400, Neil Horman wrote:
> On Wed, Mar 26, 2014 at 11:29:03AM +0000, Thomas Graf wrote:

> > What I don't understand at this point is how hiding the ports behind
> > a master device would buy us anything. We would still need to abstract
> > the filtering capabilities of the ports at some level and hiding that
> > behind existing tools seems to most convenient way.
> > 
> 
> If we agree that inconsistent frame reception / stack bypass is acceptable, then
> hiding the ports buys us nothing.  My only goal with that suggestion was to
> differentiate ports on a switch device so that the ports were differentiated in
> such a way as to make it clear that they didn't behave like typical NIC ports
> that were meant to receive host terminated traffic only.  If the consensus is
> to allows sparse reception of forwarded traffic at the cpu, then no, its not
> worthwhile and can be ignored.

I don't like the master device idea.  It just seems likely to cause
confusion.  But, we may want something to expose some topology
information to the user.  There could be situations where it is
releavant to know that two netdevs are part of the same hardware
device.

In the past I've also seen boxes with multiple switch chips tied
together either through dedicated "stacking" ports or even just with
ethernet ports directly wired together inside the box.  A variety
of combinations are possible, each with performance considerations
that might be relevant to an admin.  It would be good if we could
help them map-out such relationships.

Maybe the existing bus infrastructure (or something like it) could
be leveraged?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
