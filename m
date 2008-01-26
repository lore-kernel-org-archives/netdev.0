From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 9816] New: cannot replace route
Date: Sat, 26 Jan 2008 15:10:10 +0100
Message-ID: <20080126141010.GC2624@ami.dom.local>
References: <bug-9816-10286@http.bugzilla.kernel.org/> <20080125142603.a73fd7a2.akpm@linux-foundation.org> <479A6CBD.4010908@gmail.com> <20080125192026.e667f396.akpm@linux-foundation.org> <b25c3fa70801252116h2b9f12c9j65a8a75dbd0d5662@mail.gmail.com> <20080126114036.GA2624@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, schwab@suse.de
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:31766 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746AbYAZOGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2008 09:06:12 -0500
Received: by ug-out-1314.google.com with SMTP id z38so671340ugc.16
        for <netdev@vger.kernel.org>; Sat, 26 Jan 2008 06:06:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080126114036.GA2624@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 26, 2008 at 12:40:36PM +0100, Jarek Poplawski wrote:
> On Sat, Jan 26, 2008 at 02:16:01PM +0900, Joonwoo Park wrote:
> > 2008/1/26, Andrew Morton <akpm@linux-foundation.org>:
> > >
> > > But whatever.   It used to work.  People's scripts will break.  Regression.
> > >
> > 
> > Also I thought that 'replace with itself' should be error as like Jarek.
> > But it used to work and patch made a regression, it's my bad :(
> 
> Actually, I don't think 'replace with itself' should be an error. I've
> only meant that lack of this possibility shouldn't be necessarily seen
> as error - there could be arguments for both sides.

...On the other hand, after some re-thinking, I actually think 'replace
with itself' should be considered a bug. I wondered about the possible
reason of this behaviour in a file system, and it seems replace just
means things like overwrite, so old thing is always supposed to be
destroyed (of course it's a matter of implementation or conditions in
which moment this destruction takes place).

So, 'replace with itself' is simply ambiguous: we can always delete the
object first, to prepare the place for replacement, and find there is
nothing to do after this - and it's probably not what somebody wanted.
And, after re-reading this bugzilla report, I'm pretty sure the thing
should be done with 'ip route change' (but I didn't check if 2.6.24
knows about this...).

Jarek P.
