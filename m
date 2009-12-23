From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 10:31:29 -0800
Message-ID: <20091223183129.GB415@sequoia.sous-sol.org>
References: <4B1D4F29.8020309@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu> <200912231407.20130.bzolnier@gmail.com> <4B322FE1.2070104@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:59581 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751880AbZLWSev (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2009 13:34:51 -0500
Content-Disposition: inline
In-Reply-To: <4B322FE1.2070104@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Anthony Liguori (anthony@codemonkey.ws) wrote:
> The "poor" packet latency of virtio-net is a result of the fact that we  
> do software timer based TX mitigation.  We do this such that we can  
> decrease the number of exits per-packet and increase throughput.  We set  
> a timer for 250ms and per-packet latency will be at least that much.

Actually that's 150us ;-)  It's the AlacrityVM numbers that show 250us
(note micro, not milli) for latency.  That makes sense, shave off 150us
for the timer and you're left w/ 100us, which is not substantially
slower than what we see (for that bare metal latency we see ~60us)
when we switched tx mitigation schemes from timer based to thread
scheduling.  Quite similar to the 56.8us that vbus/venet shows.

thanks,
-chris
