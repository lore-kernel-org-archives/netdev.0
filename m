From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Bugme-new] [Bug 14749] New: Kernel locks up after a few
	minutes of heavy surfing
Date: Tue, 8 Dec 2009 07:00:21 -0500
Message-ID: <20091208120021.GA24223@hmsreliant.think-freely.org>
References: <4B1DC202.20607@gmail.com> <335647.4861.qm@web52906.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, stable@kernel.org
To: Chris Rankin <rankincj@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46356 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754307AbZLHMAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 07:00:20 -0500
Content-Disposition: inline
In-Reply-To: <335647.4861.qm@web52906.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2009 at 01:03:15AM -0800, Chris Rankin wrote:
> --- On Tue, 8/12/09, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Its all two years old UDP bugs (I spot another one some
> > hours ago), and very rare.
> 
> > I am quite suprised it could happen on your machine on
> > demand.
> 
> Who said anything about "on demand"? It took about 30 minutes to freeze last time; I was starting to think that a complete recompile had fixed it!
> 
> For the record: I've only seen that dmesg warning I've reported *once*, and that didn't kill the machine immediately (hence I was able to report it in the first place).
> 
30 minutes isn't too long to wait for an error to appear, I think.

> > 1) Do you have another NIC adapter to try ? It might be a
> > buggy driver. (Neil Horman found an error on Intel drivers some
> > hours ago, that can corrupt skbs)
> 
> I can test any patches for a e1000 that apply to 2.6.31.x. But the e1000 is an on-board device and I don't have another. But Fedora's 2.6.31.x kernels seem OK.
> 
Those patches I posted for the intel drivers will apply cleanly pretty far back
in git, as that code hasn't changed much.  You might also consider turning on
slab debugging.  Many of the errors I encountered leading up to a fatal oops
werent themselves fatal, and were hidden until such time as we used slab
debugging to catch a bunch of redzone violations.

> > 2) Could you add following debugging aid ?
> 
> Not a problem; I do have a serial console attached.
> 
> > 3) Any chance you can do a git bisect ?
> 
> How do you git-bisect a bug that you can't reproduce on demand? A negative is easy to spot, but a positive would be not experiencing a random freeze. As I said, I *almost* thought that I'd resolved the issue by recompiling last night.
Well, it sounds like your longest time to failure is about 30 minutes.  Why not
write a script that runs your test for an hour at a stretch, and plug that inot
git bisect, and walk away?  You should have results in a day or so.

Regards
Neil

