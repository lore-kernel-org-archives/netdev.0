From: Andrey Savochkin <saw@swsoft.com>
Subject: Re: [patch 1/7] net_device list cleanup: core
Date: Tue, 4 Jul 2006 11:24:05 +0400
Message-ID: <20060704112405.A25305@castle.nmd.msu.ru>
References: <20060630150823.A22285@castle.nmd.msu.ru> <20060703174650.GA22295@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Kirill Korotaev <dev@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:61200 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S1751094AbWGDHYH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 03:24:07 -0400
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060703174650.GA22295@infradead.org>; from "Christoph Hellwig" on Mon, Jul 03, 2006 at 06:46:50PM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph,

On Mon, Jul 03, 2006 at 06:46:50PM +0100, Christoph Hellwig wrote:
> On Mon, Jul 03, 2006 at 12:18:51PM +0400, Andrey Savochkin wrote:
> > Cleanup of net_device list use in net_dev core and IP.
> > The cleanup consists of
> >  - converting the to list_head, to make the list double-linked (thus making
> >    remove operation O(1)), and list walks more readable;
> >  - introducing of for_each_netdev wrapper over list_for_each.
> 
> When you change all this please make sure dev_base_head is never directly
> accessed anymore, not even through macros and dev_base_head is not exported
> anymore.  That's the only way to keep drivers messing with it.
> 
> Yes, it's a little more work as you need to audit all drivers to see what
> they are doing and find suitable abstractions but it's a must have that
> should have been done a lot earlier.

Hiding dev_base_head can be done by converting first_netdev/next_netdev into
functions and implementing for_each_netdev loop through them.

Or are you talking about abstractions like functions
for_each_netdev/find_netdev with callbacks?
Do you think that hiding the list internals is worth the additional
complexity and substantial increase of the patch size?

	Andrey
