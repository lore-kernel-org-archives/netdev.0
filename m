From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH for-next V7 00/10] Move RoCE GID management to IB/Core
Date: Sat, 1 Aug 2015 00:24:23 +0300
Message-ID: <CAJ3xEMiP57qf58B=VHRazs50RC5r-7OsUPb=GV1kBQ6vu6Tqjw@mail.gmail.com>
References: <1438270411-17648-1-git-send-email-matanb@mellanox.com>
	<CAJ3xEMh9z=LG7dW0nBP8Zdrbf0SkZ_GCxjCoowWXuw2dueN+xg@mail.gmail.com>
	<55BB6F10.5030408@redhat.com>
	<20150731163201.GA6027@obsidianresearch.com>
	<55BBB353.7020806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Matan Barak <matanb@mellanox.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Somnath Kotur <Somnath.Kotur@avagotech.com>,
	Moni Shoua <monis@mellanox.com>,
	"talal@mellanox.com" <talal@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:35335 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570AbbGaVYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 17:24:24 -0400
In-Reply-To: <55BBB353.7020806@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 31, 2015 at 8:41 PM, Doug Ledford <dledford@redhat.com> wrote:
> On 07/31/2015 12:32 PM, Jason Gunthorpe wrote:
>> On Fri, Jul 31, 2015 at 08:50:24AM -0400, Doug Ledford wrote:

>>>> So... are we ready to go with V7 upstream?
>>> Yes.  I've already pulled it in.
>> You are taking the netdev stuff without an ack from netdev??

> I've pulled it in, yes.  Dave Miller/netdev needs to ack it still.  I
> really doubt they will object to the 1st or 3rd patch, but they might
> have comments on the second.  Since they weren't copied on the original
> submission, I'll be pinging them separately.  Dave may prefer if they go
> through his tree, and that's fine, but I still need them in my tree as
> of now for testing purposes.

Doug, netdev are copied since V6 which was posed on June 24, pretty
much enough time for anyone there to comment if needed. So the
remaining thing to take care of is ask Dave if he's OK that these
patches will go upstream through your tree or his.

>> I've been too busy too look at v7, but a quick check of the 'move the
>> cache into core code stuff' looks wrong to
>> me. ib_unregister_event_handler and flush_workqueue should not/can not be
>> called from a kref free'r.

> Please be more specific here.  What are you objecting to?  Are you
> objecting to a flush_workqueue from a release() context?  Because I
> don't see anything in the kref documentation or the kref implementation
> that prevents or prohibits this.  Or are you referring to the fact that
> they aren't unregistering their event handler until well after the
> parent device is unregistered?  That's obviously wrong, but it's also
> easy to fix (the obvious fix is that they should be calling
> ib_cache_cleanup_one from the top of ib_unregister_device versus waiting
> for a kref put).

Yes, the cover letter states the v6 --> v7 changes and if this is new
complaint, then indeed @ this point it would be fair to have it
addressed in incremental patch, as Doug suggested. Jason, it's wrong
to send developers again and again to fix things which were not
perfect in Vn-1 but also not being covered by reviewers on Vn-1, at
some point the reviewer can't load new comments which gate the
acceptance but rather be willing for things to be fixed incrementally.

Or.
