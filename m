From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v3 0/6] Big C99 style initializer rework
Date: Tue, 28 Jun 2016 19:58:35 +0200
Message-ID: <20160628175835.GB6733@orbyte.nwl.cc>
References: <d6784d8bb2d84ceab6c1719e32e8fa8e@HQ1WP-EXMB11.corp.brocade.com>
 <20160627105912.7961c3f4@xeon-e3>
 <20160627182302.GB13664@orbyte.nwl.cc>
 <20160627141049.356c1eff@xeon-e3>
 <20160628173723.GA6733@orbyte.nwl.cc>
 <0a003d6f-ae2f-57cb-f3f1-1975011c7b78@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35015 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752006AbcF1R5D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 13:57:03 -0400
Content-Disposition: inline
In-Reply-To: <0a003d6f-ae2f-57cb-f3f1-1975011c7b78@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 28, 2016 at 11:37:43AM -0600, David Ahern wrote:
> On 6/28/16 11:37 AM, Phil Sutter wrote:
> >>> I saw these too with gcc-3.4.6 but not with 5.3.0. It appears to be a
> >>> gcc bug[1]. One possible workaround is to match the brace level of the
> >>> first field, but it's quite ugly: [2]. Another way might be to
> >>> initialize one of the fields to zero, like so:
> >>>
> >>> | struct ifreq ifr = { .ifr_qlen = 0 };
> >>>
> >>> What do you think?
> >>>
> >>> Thanks, Phil
> >>>
> >>> [1] https://gcc.gnu.org/bugzilla/show_bug.cgi?id=53119
> >>> [2] http://nwl.cc/cgi-bin/git/gitweb.cgi?p=iproute2.git;a=commitdiff;h=a1cbf2b63c995b2f633c5b4699248ab308b201d2;hp=3809cfec65b03716d1d0360338126df4b4f3fbf6
> >>
> >> I am using gcc on Debian stable which is 5.3.1.
> >
> > Hmm. In a fresh install of Debian 8.5 I see the warnings as well, but it
> > has gcc-4.9.2-10 as most recent version.
> >
> > Another thing I noticed: Using empty braces ('{}') instead of the
> > universal zero initializer seems to work without causing warnings (at
> > least unless '-pedantic' is used).
> 
> since .ifr_qlen is already referenced in that function seems like your 
> suggestion above (struct ifreq ifr = { .ifr_qlen = 0 };) should be 
> acceptable.

You mean regarding compatibility of using that define? Or are you
concerned with gcc creating suboptimal code?

I'd rather use a more generic approach than the above. Retrospectively,
I'd rather have that brace orgy instead of the above since it's
intention is more clear and it can be dropped once either gcc guys
manage to backport their fix or the last distribution has updated it's
compiler.

Cheers, Phil
