From: Jakub Jelinek <jakub@redhat.com>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 11:44:41 -0400
Message-ID: <20080424154441.GG2255@devserv.devel.redhat.com>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com> <20080424112514.055d8071@the-village.bc.nu> <481096C3.2020206@redhat.com> <20080424152436.6cf53c1b@the-village.bc.nu> <4810A46B.1090809@redhat.com> <20080424160352.30f2dd5b@the-village.bc.nu>
Reply-To: Jakub Jelinek <jakub@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ulrich Drepper <drepper@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49704 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758072AbYDXPpZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 11:45:25 -0400
Content-Disposition: inline
In-Reply-To: <20080424160352.30f2dd5b@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2008 at 04:03:52PM +0100, Alan Cox wrote:
> > > Every other property of a socket via accept() is inherited from the
> > > parent. Making one property different would be bizarre and ugly.
> > 
> > Implementing this would visibly change existing code and it would
> > actively violate POSIX.  Not a good idea.
> 
> POSIX has no interface for this new behaviour you propose so that is
> complete crap. The moment you use one of these features you stepped
> outside of the POSIX spec - and you know that. If there was an existing
> standard we wouldn't have a problem.

Doing:

int fd = socket (PF_INET, SOCK_STREAM, 0);
fcntl (fd, F_SETFD, F_CLOEXEC);
...
int fd2 = accept (fd, addr, addrlen);

certainly doesn't use any of the new interfaces, yet if accept inherits
the CLOEXEC flag from the socket, would visibly change existing programs.

	Jakub
