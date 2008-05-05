From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Need help debugging memory corruption
Date: Mon, 5 May 2008 07:27:34 +0000
Message-ID: <20080505072734.GA4069@ff.dom.local>
References: <20080503130951.091392ba@osprey.hogchain.net> <481DC731.5090303@gmail.com> <481DCE4C.9070805@gmail.com> <20080504145529.2eac672e@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Chris Snook <csnook@redhat.com>
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:63251 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753992AbYEEHYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 03:24:18 -0400
Received: by ug-out-1314.google.com with SMTP id h3so689246ugf.16
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 00:24:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080504145529.2eac672e@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 04, 2008 at 02:55:29PM -0500, Jay Cliburn wrote:
> On Sun, 04 May 2008 16:55:08 +0200
> Jarek Poplawski <jarkao2@gmail.com> wrote:
> 
> > Jarek Poplawski wrote, On 05/04/2008 04:24 PM:
> > ...
> > 
> > > I'm definitely with less experience, so I wonder why it can't be
> > > a simple race between atl1_clean_rx_ring() and something (maybe even
> > > pending atl1_intr_rx()) on the other cpu writing skb while kfreeing?
> > 
> > 
> > Hmm... atl1_intr_rx() looks impossible, so atl1_alloc_rx_buffers()?
> 
> I booted with nosmp and the bug is *much* harder to hit, but I still
> hit it once out of about 10 tries.  Does the fact that I hit it once
> using nosmp disprove the race theory?

Probably not: I don't know how about preemption model, but especially
some maybe unkilled timers/watchdogs or workqueues could be considered.
Of course this idea looks very unprobable (should happen with less
than 4GB too), but should be quite easy to verify by adding some
temporary spinlocks around these rx ring operations?

Jarek P.
