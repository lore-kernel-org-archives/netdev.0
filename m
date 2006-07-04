From: Andrey Savochkin <saw@swsoft.com>
Subject: Re: [patch 1/7] net_device list cleanup: core
Date: Tue, 4 Jul 2006 18:50:35 +0400
Message-ID: <20060704185035.A29778@castle.nmd.msu.ru>
References: <20060630150823.A22285@castle.nmd.msu.ru> <20060703174650.GA22295@infradead.org> <20060704112405.A25305@castle.nmd.msu.ru> <20060704091003.GA17961@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Kirill Korotaev <dev@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:24582 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S932264AbWGDOug
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 10:50:36 -0400
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060704091003.GA17961@infradead.org>; from "Christoph Hellwig" on Tue, Jul 04, 2006 at 10:10:03AM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 04, 2006 at 10:10:03AM +0100, Christoph Hellwig wrote:
> On Tue, Jul 04, 2006 at 11:24:05AM +0400, Andrey Savochkin wrote:
> > > Yes, it's a little more work as you need to audit all drivers to see what
> > > they are doing and find suitable abstractions but it's a must have that
> > > should have been done a lot earlier.
> > 
> > Hiding dev_base_head can be done by converting first_netdev/next_netdev into
> > functions and implementing for_each_netdev loop through them.
> > 
> > Or are you talking about abstractions like functions
> > for_each_netdev/find_netdev with callbacks?
> 
> an for_each_netdev with a callback makes sense and gives a cleaner
> abstraction, yes.  I don't think you should need a callback for the lookup
> structure.

Different modules want different kinds of lookup.
So, I'm thinking about something like ilookup5.

> 
> > Do you think that hiding the list internals is worth the additional
> > complexity and substantial increase of the patch size?
> 
> Yes, absolutely.  We've converted scsi hosts and devices from a model
> where drivers could directly access the list to strict iterators in the
> 2.5 series.  It's quite a lot of work as you have to understand what
> the drivers actually do (and to at least 50% they were doing something
> really stupid) and convert them to the right abstractions.

The next question: would people agree to review a patch doing this for
net_devices? :)

	Andrey
