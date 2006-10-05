From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: Request to postpone WE-21
Date: Thu, 5 Oct 2006 14:21:39 -0700
Message-ID: <20061005212139.GA7397@bougret.hpl.hp.com>
References: <20061005163113.GB6510@bougret.hpl.hp.com> <20061005204949.GF18408@tuxdriver.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: liniville@bougret.hpl.hp.com, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:39414 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S1751398AbWJEVWV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 17:22:21 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20061005204949.GF18408@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2006 at 04:49:54PM -0400, John W. Linville wrote:
> On Thu, Oct 05, 2006 at 09:31:13AM -0700, Jean Tourrilhes wrote:
> 
> > 	Based on the feedback, I formally request you to back out all
> > of WE-21 from 2.6.19. Rationale : it's probably too early. You can
> > keep it for a later date if you wish.
> 
> Jean,

	Let me say I truly apreciate your effort to bring progress to
the discussion.

> What about a patch like the one below?  It tries to detect WE-20
> ESSID/NICKN accesses and adjust them to WE-21 style.  What am
> I missing?

	The idea is clever.
	The GET is no longer an issue. WE had half the driver doing
the GET "new style" since january, so in a sense the API change has
already happened, and I've already dealt with the bug reports. So, I
think we could drop the "GET" part.
	As you may have noticed, detecting the API for the GET is
easy. On the other hand, detecting it for the SET is not clear cut. As
Jouni was pointing out, '\0' is a valid ESSID character, and in the
long term we want to allow it, even if it's in the last position.
	I'm also wondering if this additional complexity could not
bring additional trouble, but I'm not currently clear on that. I
usually prefer things to be a bit more explicit.

> I haven't had a chance to test it yet -- just hacked it
> up...YMMV... :-)

	And I thing there is a couple of way we could refine the
implementation, if ever we decide to go that way.
	For example, the correction could happen after real
copy_from_user(), as the uncorrected iwr->u.data.length is always the
number of char to pass between kernel and userspace. I think this
would simplify drastically the code.
	I'll try to check that.

> John

	Thanks again...

	Jean
