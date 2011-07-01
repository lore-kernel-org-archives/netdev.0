From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Fri, 1 Jul 2011 12:16:25 +0200
Message-ID: <20110701101625.GB3988422@jupiter.n2.diac24.net>
References: <BANLkTikDqjErqBmfwrN6SJPgPjmmMfJw7g@mail.gmail.com>
 <20110628185811.GA2121496@jupiter.n2.diac24.net>
 <BANLkTi=goXU4SpP6dxX9C+YeLcVMEkcKHw@mail.gmail.com>
 <20110628202200.GB2121496@jupiter.n2.diac24.net>
 <BANLkTim1owW7iMS3hgKhm7DzTzE4X-jxHA@mail.gmail.com>
 <20110628210434.GD2121496@jupiter.n2.diac24.net>
 <BANLkTikN_TPPcyywVT5W9CrGAFJX8qQiyQ@mail.gmail.com>
 <20110628214637.GE2121496@jupiter.n2.diac24.net>
 <BANLkTi=4-xYNyaBOzeL04VioK8D0Q8secg@mail.gmail.com>
 <20110629163423.1d73b0ef@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nick Carter <ncarter100@gmail.com>,
	David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:49516 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755677Ab1GAKQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2011 06:16:35 -0400
Content-Disposition: inline
In-Reply-To: <20110629163423.1d73b0ef@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2011 at 04:34:23PM -0700, Stephen Hemminger wrote:
> The problem is that the damn 802.1 committees keep loading up protocols
> on the same multicast address range. Trying to solve a design committee 
> problem in the kernel is not going to make anybody happy.
> 
> I am happy with the simple solution of:
>   no STP == Hub
>   STP    == Bridge
> These are both well know configurations and are blessed by standards.

I agree, that is how we should behave by default, and we'll match most
admin's expectations.

Regarding multicast groups, I would summarise like this:
1. any multicast gets forwarded by default,
 2. unless it is 01:80:c2:00:00:01 or :02 (pause/bonding)
    (this rule applies regardless of STP state)
 3. if STP is on:
  4. 01:80:c2:00:00:00 (STP) never gets forwarded
  5. 01:80:c2:00:00:03-0f don't get forwarded by default

What we can do is add a switch to disable the #5 rule. The way I see it
is that that switch would remove an exception from the rule and turn it
back to the default #1; that's acceptable for making a new knob in my
eyes.

(Adding an 802.1X knob would be an exception to the exception for me,
which is why I'm against it.)

I'll cook up a patch in a few minutes, we really need to get rule #2
right anyway. We _MUST_NOT_ pass bonding frames in any case, but we
currently do that if STP is off. (cf. my earlier patch 1/2)


-David

