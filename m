From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Kernel header changes break glibc build
Date: Wed, 6 Dec 2006 15:31:46 +0100
Message-ID: <20061206143146.GD8693@postel.suug.ch>
References: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk> <1165148731.12649.51.camel@pmac.infradead.org> <20061204091341.GM8693@postel.suug.ch> <1165410114.5253.218.camel@pmac.infradead.org> <20061206134308.GL9556@sunsite.mff.cuni.cz> <20061206135931.GB8693@postel.suug.ch> <1165414039.5253.233.camel@pmac.infradead.org> <20061206141841.GN9556@sunsite.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>,
	Ulrich Drepper <drepper@redhat.com>,
	"Joseph S. Myers" <joseph@codesourcery.com>,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:48254 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760629AbWLFOb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 09:31:26 -0500
To: Jakub Jelinek <jakub@redhat.com>
Content-Disposition: inline
In-Reply-To: <20061206141841.GN9556@sunsite.mff.cuni.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jakub Jelinek <jakub@redhat.com> 2006-12-06 15:18
> There are the kernel's own headers and kernel ABI headers for userland use.
> Until recently the latter has been maintained by various distributions
> and manually occassionally updated to sync a little bit with kernel ABI
> additions (new syscalls, etc.)., but now, thanks to David, these are
> generated from kernel's own headers.  If the macros were part of
> such ABI

Macros can't possibly be part of an ABI :-) You probably mean API.

> (I don't think these macros were meant to be #ifdef __KERNEL__
> and just by omission exported to userland), then if you change
> the kernel headers (which of course you can do, that's kernel private
> headers), then you IMNSHO should also add magic to make headers_install
> to keep the kernel ABI headers for userland headers stable.

At the time they were added they were meant to be exported but netlink
has evolved and we now have a type safe API. Guess what, I'm going to
remove more bits of the old interface because they are no longer needed.

> Which in this case would mean if you decide rtnetlink.h shouldn't include
> the newly added if_addr.h that you add rules for generating the userland
> rtnetlink.h such that it will include linux/if_addr.h and define the
> macros you intentionally omitted.

Sure, moving these bits to some compat header which gets automatically
included by make install_headers instead of removing them sounds
like a good compromise, it just has to be clear that they are deprecated
and not supposed to be used by new code.
