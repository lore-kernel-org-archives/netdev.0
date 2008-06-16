From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: bnx2_poll panicking kernel
Date: Mon, 16 Jun 2008 15:04:55 +0100
Message-ID: <20080616140454.GD5350@solarflare.com>
References: <20080616125735.GA5967@orion.carnet.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mirrors@debian.org
To: Josip Rodin <joy@entuzijast.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from doppler.zen.co.uk ([212.23.3.27]:42615 "EHLO doppler.zen.co.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753643AbYFPOaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 10:30:07 -0400
Content-Disposition: inline
In-Reply-To: <20080616125735.GA5967@orion.carnet.hr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Josip Rodin wrote:
> Hi,
> 
> Has anyone seen the below bug before? I'm already upgrading in hope that it
> might be already fixed in a newer kernel, but anyway.
> 
> It started happening a few days ago, on a load of a few tens of MB/s (Debian
> rsync mirroring). It doesn't happen on every mirror pulse, so it's not
> exactly reproducible...

That might be a result of the bug fixed by this commit, which would be
triggered by heavy traffic:

commit 6f535763165331bb91277d7519b507fed22034e5
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Thu Oct 11 18:08:29 2007 -0700

    [NET]: Fix NAPI completion handling in some drivers.

    In order for the list handling in net_rx_action() to be
    correct, drivers must follow certain rules as stated by
    this comment in net_rx_action():

                /* Drivers must not modify the NAPI state if they
                 * consume the entire weight.  In such cases this code
                 * still "owns" the NAPI instance and therefore can
                 * move the instance around on the list at-will.
                 */

    A few drivers do not do this because they mix the budget checks
    with reading hardware state, resulting in crashes like the one
    reported by takano@axe-inc.co.jp.

    BNX2 and TG3 are taken care of here, SKY2 fix is from Stephen
    Hemminger.

This fix went into 2.6.24.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
