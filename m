From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 00/30] Kernel NET policy
Date: Mon, 18 Jul 2016 12:43:57 -0700
Message-ID: <20160718194357.GL5871@two.firstfloor.org>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
 <20160718151841.GA19066@breakpoint.cc>
 <20160718154512.GK5871@two.firstfloor.org>
 <7a03a353-4c1e-2bb4-2550-f84fc4cc79ac@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Florian Westphal <fw@strlen.de>,
	kan.liang@intel.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	mingo@redhat.com, peterz@infradead.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, jesse.brandeburg@intel.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([193.170.194.197]:46621 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313AbcGRToB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 15:44:01 -0400
Content-Disposition: inline
In-Reply-To: <7a03a353-4c1e-2bb4-2550-f84fc4cc79ac@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I wonder if this can be attacked from a different angle. What would be
> missing to add support for this in user space? The first possibility
> that came to my mind is to just multiplex those hints in the kernel.

"just" is the handwaving part here -- you're proposing a micro kernel
approach where part of the multiplexing job that the kernel is doing
is farmed out to a message passing user space component.

I suspect this would be far more complicated to get right and
perform well than a straight forward monolithic kernel subsystem --
which is traditionally how Linux has approached things.

The daemon would always need to work with out of date state
compared to the latest, because it cannot do any locking with the
kernel state.  So you end up with a complex distributed system with multiple
agents "fighting" with each other, and the tuning agent
never being able to keep up with the actual work.

Also of course it would be fundamentally less efficient than
kernel code doing that, just because of the additional context
switches needed.

-Andi
