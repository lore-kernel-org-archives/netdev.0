From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] avoid OPEN_MAX in SCM_MAX_FD
Date: Tue, 13 Mar 2007 14:28:00 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0703131420230.9690@woody.linux-foundation.org>
References: <20070313200256.CF7411801C5@magilla.sf.frob.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Benjamin LaHaise <bcrl@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Roland McGrath <roland@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36166 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933640AbXCMV2Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 17:28:16 -0400
In-Reply-To: <20070313200256.CF7411801C5@magilla.sf.frob.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 13 Mar 2007, Roland McGrath wrote:
> 
> The OPEN_MAX constant is an arbitrary number with no useful relation to
> anything.  Nothing should be using it.  SCM_MAX_FD is just an arbitrary
> constant and it should be clear that its value is chosen in net/scm.h
> and not actually derived from anything else meaningful in the system.

I'd actually prefer this as part of the "remove OPEN_MAX" patch.

It's certainly nice to have small independent patches in a series, but two 
one-liners that really aren't all that independent either in practice or 
in goals doesn't make much sense to me. Much better to just be up-front 
about things and say: "remove OPEN_MAX, and to do so, just rewrite that 
other arbitrary constant to not need it any more".

That said, it actually worries me that you should call "_SC_OPEN_MAX". I 
think the whole POSIX config method is way over-designed (anybody who 
thinks you should ever have used _SC_HZ or whatever it was called was just 
crazy), but more importantly, and independently of that worry, I just 
suspect a lot of programs simply _don't_do_it_.

For example, I know perfectly well that I should use _SC_PATH_MAX, but a 
*lot* of code simply doesn't care. In git, I used PATH_MAX, and the reason 
is that
 - I want a constant for arrays
 - I don't care that much about the exact value, I just want a reasonable 
   value for sizing an array for some random path
 - _SC_PATH_MAX is practically unportable and simply not *useful*.

.. in short, I'm not a big believer in "programs should do Xyz according 
to some paper standard". Paper standards are written by committees, not 
programmers, and seldom take issues other than politics into account.

So, what's the likelihood that this will break some old programs? I 
realize that modern distributions don't put the kernel headers in their 
user-visible includes any more, but the breakage is most likely exactly 
for old programs and older distributions.

		Linus
