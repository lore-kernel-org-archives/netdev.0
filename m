From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH 0/8]: uninline & uninline
Date: Sat, 23 Feb 2008 12:11:49 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0802231004450.29504@kivilampi-30.cs.helsinki.fi>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20080223000220.e9229c99.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52931 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754109AbYBWKMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 05:12:01 -0500
In-Reply-To: <20080223000220.e9229c99.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Feb 2008, Andrew Morton wrote:

> On Wed, 20 Feb 2008 15:47:10 +0200 "Ilpo J__rvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > -41525  2066 f, 3370 +, 44895 -, diff: -41525  IS_ERR 
> 
> This is a surprise. 

It surprised me as well, there were something like 10 bytes I just 
couldn't explain in IS_ERR size (kernel/uninlined.c: IS_ERR | +25). I was 
to look into it deeper but didn't have the .o's at hand right away, not so 
trivial to store results of 5000+ build results except some carefully 
picked textual output :-)... Hmm, I'll add logging for the disassembly of 
the uninlined stuff into the next run, that won't cost too much...

> I expect that the -mm-only
> profile-likely-unlikely-macros.patch is the cause of this and mainline
> doesn't have this problem.

Ahaa, this explain it, I suspected that there was something (un)likely 
related elsewhere as well, no wonder why I couldn't reproduce the 25 bytes 
result in my quick copy-pasted non-kernel test...

> If true, then this likely/unlikely bloat has probably spread into a lot of
> your other results and it all should be redone against mainline, sorry :(

It isn't that troublesome to redo them, it's mainly automatic combined 
with impatient waiting from my behalf :-)... The spreading problem is 
probably true, to some extent. I did some runs also with carefully 
selected CONFIG.*DEBUG.* off under include/net/ earlier, in general it 
made very little difference, if something bloats, it usually does that 
regardless of .config. There are probably couple of exceptions when the 
size is on the boundary where it's very close of being useful to uninline 
it.

One interesting thing in there was that the largest offenders are quite 
small per call-site but due to vast number of them even a small benefit 
buys off a lot in kernel wide results. I suspect the differences due to 
(un)likely will be negligle, because the IS_ERR with all its trivialness 
is now mostly -15, so anything clearly larger than that will likely still 
be a win x n (where n is quite large).

Anyway, I'll see when I get the new set of tests running... :-) I'd prefer 
with CONFIG.*DEBUG off to get larger picture about non-debug builds too
(especially the scatterlist.h things interest me a lot), do you think that 
would do as well?

Thanks for your comments, I found them very useful.


-- 
 i.
