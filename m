From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Kernel header changes break glibc build
Date: Thu, 07 Dec 2006 11:29:21 +0000
Message-ID: <1165490961.5253.278.camel@pmac.infradead.org>
References: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk>
	 <1165148731.12649.51.camel@pmac.infradead.org>
	 <20061204091341.GM8693@postel.suug.ch>
	 <1165410114.5253.218.camel@pmac.infradead.org>
	 <20061206134308.GL9556@sunsite.mff.cuni.cz>
	 <20061206135931.GB8693@postel.suug.ch>
	 <1165414039.5253.233.camel@pmac.infradead.org>
	 <20061206142327.GC8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jakub Jelinek <jakub@redhat.com>,
	Ulrich Drepper <drepper@redhat.com>,
	"Joseph S. Myers" <joseph@codesourcery.com>,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:52008 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032056AbWLGL31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 06:29:27 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061206142327.GC8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-12-06 at 15:23 +0100, Thomas Graf wrote:
> > I'm suggesting that if you want to change things around as you did, you
> > should make sure the users of those headers adapt to cope. You did fix
> > the in-kernel users; you neglected to fix glibc -- and as far as I can
> > tell you didn't even bother to _warn_ glibc folks.
> 
> I didn't warn them because I didn't know better. 

Fair enough. Now you do -- and thanks for fixing it.

> I was under the impression that glibc still maintains their own set of
> headers and will fix this automatically when they look at the diff.
> That's what I do for my userspace applications that use kernel
> headers.

That's never been the case for glibc. As I said, various people have
_attempted_ to do it, but it really isn't a workable approach and the
results were wildly inconsistent. Having a single, centrally-exported
set of headers is a massive improvement -- but yes, it does mean we have
to take a little care with what we're exporting to userspace.

> Ideally install_headers would do the trick but it often fails f.e.
> when some application which uses bsd features thus including net/if.h
> also wants to use new linux features and includes linux/if.h which
> then conflicts.

Applications in general shouldn't be doing that -- kernel headers are
for system libraries and tools only. We should try to ensure that the
_sensible_ use cases don't break, but we don't have to go overboard with
keeping our namespace clean and anticipating _every_ strange thing which
a userspace app might do with our headers -- we still get to say 'caveat
emptor'; it's just that we can't be _quite_ as haphazard about it as
we've been in the past.

-- 
dwmw2

