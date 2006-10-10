From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: Request to postpone WE-21
Date: Tue, 10 Oct 2006 13:28:03 -0700
Message-ID: <20061010202803.GA17177@bougret.hpl.hp.com>
References: <20061005163113.GB6510@bougret.hpl.hp.com> <20061005204949.GF18408@tuxdriver.com> <20061005221246.GB7533@bougret.hpl.hp.com> <20061010193959.GC5728@tuxdriver.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <jkm@devicescape.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:3307 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S1030289AbWJJU2w
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 16:28:52 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20061010193959.GC5728@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 10, 2006 at 03:40:04PM -0400, John W. Linville wrote:
> 
> I think this patch still has two problems.  One is that the length
> modification does not happen until after the "Check what user space
> is giving us" clause.  So, max length requests will fail.  (Did you
> check SIOCGIWESSID w/ WE-20 tools?  Or am I missing something?
> SIOCGIWESSID and SIOCGIWNICN do not have IW_DESCR_FLAG_NOMAX set.)

	Yes, I can see that SET with 32 char would get rejected. I did
not check 32 char with WE-20 tools. I don't know how widely 32 char
ESSID are used in the real world.

	Over the week end, I tought about another potential gotcha,
however I don't think it would happen in practice. A tool could send a
non NUL terminated ESSID with WE-20, just adding a dummy char at the
end of the ESSID. That would work with most drivers.

> Since I think we have to account for the gets as well as the sets,
> then we have to restore the length value in the ifreq to be compatible
> with userland, just in case they reuse the data structure.

	The GET API change *already* happened last January. It's
already a reality, and WE-21 did not really change anything about
that. This means that it's already included in "2.6.16", which is the
"somewhat more stable" kernel, and widely diffused.
	There was userspace issues with that. Those have been fixed a
long time ago. I don't see the point of carrying code for those cases.

> I think the main issues with my patch were an off-by-one in the length
> for checking for \0, and a failure to account for a length of zero.
> I have attempted to correct those in my patch below.  What do you
> think?
> 
> John
> 
> P.S.  Again, this is an untested patch...

	Compile Wireless Tools 27 with a static iwlib (top of
Makefile) to do your testing, so that you can run without having to
install it. And use a driver that care about the ending NUL, such as
the Broadcom or IPW2x00.

	Have fun...

	Jean
