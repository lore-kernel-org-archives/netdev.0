From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/4] DST: Distributed storage documentation.
Date: Mon, 10 Dec 2007 18:12:25 +0300
Message-ID: <20071210151225.GA17858@2ka.mipt.ru>
References: <11972872493977@2ka.mipt.ru> <11972872501664@2ka.mipt.ru> <3ae72650712100451h6a84d6cfs9b3a2954c13c4612@mail.gmail.com> <20071210125839.GA16789@2ka.mipt.ru> <1197297108.6399.91.camel@lov.site> <20071210145055.GB7184@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, Greg KH <greg@kroah.com>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59600 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601AbXLJPM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 10:12:28 -0500
Content-Disposition: inline
In-Reply-To: <20071210145055.GB7184@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 10, 2007 at 05:50:55PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > Further questions:
> > Why do you do your own refcounting instead of using kref?
> 
> That's because I always used atomic operations as a reference counters
> and did not tried krefs :)
> They are the same actually (module tricky arches where smp_mb_* are
> required), so I can replace them in the next release.

Actually not - I have to set reference counter to something other than 1
or +/- 1, and thus will have to call kref_get() in a loop, which is a
very ugly step. Is there kref_set() or somethinglike that? At least not
in 2.6.22 what I'm using for now.

Sigh, I've converted most of the DST already...

-- 
	Evgeniy Polyakov
