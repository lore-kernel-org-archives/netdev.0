From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 1/7] net_device list cleanup: core
Date: Tue, 4 Jul 2006 10:10:03 +0100
Message-ID: <20060704091003.GA17961@infradead.org>
References: <20060630150823.A22285@castle.nmd.msu.ru> <20060703174650.GA22295@infradead.org> <20060704112405.A25305@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	Kirill Korotaev <dev@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:55712 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751094AbWGDJKI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 05:10:08 -0400
To: Andrey Savochkin <saw@swsoft.com>
Content-Disposition: inline
In-Reply-To: <20060704112405.A25305@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 04, 2006 at 11:24:05AM +0400, Andrey Savochkin wrote:
> > Yes, it's a little more work as you need to audit all drivers to see what
> > they are doing and find suitable abstractions but it's a must have that
> > should have been done a lot earlier.
> 
> Hiding dev_base_head can be done by converting first_netdev/next_netdev into
> functions and implementing for_each_netdev loop through them.
> 
> Or are you talking about abstractions like functions
> for_each_netdev/find_netdev with callbacks?

an for_each_netdev with a callback makes sense and gives a cleaner
abstraction, yes.  I don't think you should need a callback for the lookup
structure.

> Do you think that hiding the list internals is worth the additional
> complexity and substantial increase of the patch size?

Yes, absolutely.  We've converted scsi hosts and devices from a model
where drivers could directly access the list to strict iterators in the
2.5 series.  It's quite a lot of work as you have to understand what
the drivers actually do (and to at least 50% they were doing something
really stupid) and convert them to the right abstractions.
