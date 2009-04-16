From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 14:54:21 -0700
Message-ID: <OF1E984792.6ED16C23-ON8825759A.0076BEC6-8825759A.0078542C@us.ibm.com>
References: <alpine.DEB.1.10.0904161659440.7855@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	vladislav.yasevich@hp.com
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:55699 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbZDPVyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 17:54:25 -0400
In-Reply-To: <alpine.DEB.1.10.0904161659440.7855@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter <cl@linux.com> wrote on 04/16/2009 02:04:30 PM:

> Guess its the obvious: Software should run on multiple OSes without
> too much special casing. Linux is the only special case that I am aware 
of
> that misbehaves.

        All flavors of UNIX did it this way originally. I never tried
it on Windows. I heard years ago when Solaris changed their behavior
and it's been reported in this thread that current BSD does, too.
But, again, this is not in the least misbehavior. It simply doesn't
follow your model of how you thought it behaved. Linux does exactly
what Steve Deering wanted multicasting to do when he wrote the RFC
for it. It adds an address on the interface, and the binding determines
whether it's delivered to a particular socket or not. That is the
"ANY" in INADDR_ANY, just like unicasting. If you want particular
addresses only, the bind system call does that already. It makes
perfect sense to me.
 
> Adding a socket is no easy thing given the architecture of the software
> (and of other software) that did not consider that Linux faithfully
> replicating bugs from 25 years ago that no longer exist in other OSes.

        I don't have any say in what other OSes do, but I'd call it a bug
in them, too. 

> Cannot imagine there to be too much software out there that relies on 
this
> strange behavior. Otherwise the software would not work on various other
> platforms.

        I don't know the extent of your survey, but Linux legacy is the
problem with changing the default behavior for sockets other than your
app. You don't need any special code at all-- write them all to assume
they may receive packets not for them, because they are broken if they
don't. That works fine on Solaris, too.

> Can you give us a list of products that verifiably rely on the current
> behavior?

        I don't do app surveys any more than you do OS surveys. But
I don't want to change the semantics of multicast sockets and you do.
Can you guarantee nothing will break from this change?

                                                                +-DLS

