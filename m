From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 12/15] driver core: Implement tagged directory support for device classes.
Date: Fri, 04 Jul 2008 15:00:36 -0700
Message-ID: <m1od5d71iz.fsf@frodo.ebiederm.org>
References: <20080618170729.808539948@theryb.frec.bull.fr>
	<m1hcb7o8lv.fsf@frodo.ebiederm.org> <486CB051.5000507@fr.ibm.com>
	<m14p77m9uy.fsf@frodo.ebiederm.org> <486CF71F.5090405@gmail.com>
	<m1y74iiidz.fsf_-_@frodo.ebiederm.org>
	<m1tzf6ihlz.fsf_-_@frodo.ebiederm.org>
	<m1prpuihjb.fsf_-_@frodo.ebiederm.org>
	<m1lk0iihhp.fsf_-_@frodo.ebiederm.org>
	<m1hcb6ihfz.fsf_-_@frodo.ebiederm.org>
	<m1d4luihea.fsf_-_@frodo.ebiederm.org>
	<m18wwiihbn.fsf_-_@frodo.ebiederm.org>
	<m14p76ih9a.fsf_-_@frodo.ebiederm.org>
	<m1zloyh2mb.fsf_-_@frodo.ebiederm.org>
	<m1vdzmh2jr.fsf_-_@frodo.ebiederm.org>
	<m1r6aah2hh.fsf_-_@frodo.ebiederm.org>
	<m1mykyh2fu.fsf_-_@frodo.ebiederm.org>
	<m1hcb6h2d2.fsf_-_@frodo.ebiederm.org> <486DD650.3000804@gmail.com>
	<m1tzf593ny.fsf@frodo.ebiederm.org> <486E2C3B.6020603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:40087 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752445AbYGDWBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 18:01:42 -0400
In-Reply-To: <486E2C3B.6020603@gmail.com> (Tejun Heo's message of "Fri, 04 Jul
	2008 22:57:15 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tejun Heo <htejun@gmail.com> writes:

> Yeah, it seems we should agree to disagree here.  I think using callback
> for static values is a really bad idea.  It obfuscates the code and
> opens up a big hole for awful misuses.  Greg, what do you think?

The misuse argument is small because currently all users must be compiled
into the kernel and must add to the static enumeration.  I'm afraid we
are making the facility over general for the problem at hand.

> As we're very close to rc1 window, I think we can work out a solution
> here.  The reason why I nack'd was because the change wouldn't take too
> much effort and I thought it could be done before -rc1.  Unless you
> disagree with making tags static values, I'll try to write up a patch to
> do so.  If you (and Greg) think the callback interface is better, we can
> merge the code as-is and update (or not) later.

Making a change and pushing down into the patches is much more time intensive
then I would like.  The last round of changes simple as they were took something
between 16 and 30 hours, and has left me sapped.  Keeping all of the other
pieces in flight in all of the other patches so I can't just focus on the
change at hand is what makes it difficult at this point.

Adding an additional patch on top isn't too bad, but my creativity is sapped on
this right now.  I agree that a function called device_rename isn't the best
possible name when we are changing tags, but I can't think of anything that
seems better.

I know in the users that the tags are already quite static and that I call
kobject_rename in the one case where they change (which is a significant
exception).  So that part doesn't concern me as I have not intention of using
the interface like that.  Ultimately I don't care as long as we have code
that works.

Eric
