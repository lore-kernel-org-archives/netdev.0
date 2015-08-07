From: David Miller <davem@davemloft.net>
Subject: Re: [v4, 0/9] Freescale DPAA FMan
Date: Fri, 07 Aug 2015 15:31:02 -0700 (PDT)
Message-ID: <20150807.153102.533553009548852567.davem@davemloft.net>
References: <1438766725-8053-1-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, scottwood@freescale.com,
	madalin.bucur@freescale.com, pebolle@tiscali.nl,
	joakim.tjernlund@transmode.se, ppc@mindchasers.com,
	stephen@networkplumber.org
To: igal.liberman@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438766725-8053-1-git-send-email-igal.liberman@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <igal.liberman@freescale.com>
Date: Wed, 5 Aug 2015 12:25:16 +0300

> The Freescale Data Path Acceleration Architecture (DPAA)
> is a set of hardware components on specific QorIQ multicore processors.
> This architecture provides the infrastructure to support simplified
> sharing of networking interfaces and accelerators by multiple CPU cores
> and the accelerators.

I think the directory and code structure of this new driver is
quite excessive.

Because you've split things up _so_ much, you have to have
all of these directories, and even worse and much more important
to me you have to export so many functions from one source file
to another.

I think this is way too much.

For example, in one file you have a bunch of initialization routines.
init_a(), init_b(), init_c(), and you export them all.  Then they
are always called in sequence:

	init_a();
	init_b();
	init_c();

This is completely pointless.  You just needed to export one
function which calls all three functions.

The namespace pollution of this driver is out of control.

You really need to completely rework the architecture and
layout of this driver before I will even begin to review it
again.

And the lack of review interest by other developers should be an
indication to you how undesirable this code submission is to read.

Thanks.
