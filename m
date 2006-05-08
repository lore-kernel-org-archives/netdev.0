From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] core: linkwatch should use jiffies64
Date: Sun, 07 May 2006 23:07:27 -0700 (PDT)
Message-ID: <20060507.230727.67882043.davem@davemloft.net>
References: <200605071213.56877.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55477
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932303AbWEHGHU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 02:07:20 -0400
To: stefan@loplof.de
In-Reply-To: <200605071213.56877.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Rompf <stefan@loplof.de>
Date: Sun, 7 May 2006 12:13:56 +0200

> the linkwatch code can overflow on a jiffies wrap, scheduling
> work with a too large delay. If the delay is >0x80000000,
> internal_add_timer() seems to overflow too, hiding the bug, so
> this isn't triggered too easily.

What is so special about what linkwatch is doing such
that it needs this kind of treatment and other similar
pieces or code do not?

We have all sorts of interfaces such as time_after() et el.
in order to deal with wrapping issues.  And furthermore
using 64-bit jiffies here might not be appropriate because
they are not guarenteed to be accessed atomically, nothing
here prevents the upper 32-bits from being updated while
we sample the lower 32-bits on 32-bit systems that will do
the 64-bit jiffied load using two 32-bit loads.
