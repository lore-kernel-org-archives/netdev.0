From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH 0/10] d80211: move away from wmaster towards wiphy
Date: Fri, 17 Nov 2006 18:24:17 -0500
Message-ID: <1163805857.2909.34.camel@dv>
References: <1163802439.3392.47.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:54942 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1756027AbWKQXYV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 18:24:21 -0500
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1GlD4F-00078V-Sn
	for netdev@vger.kernel.org; Fri, 17 Nov 2006 18:24:20 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1163802439.3392.47.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Johannes,

On Fri, 2006-11-17 at 23:27 +0100, Johannes Berg wrote:

> Since it looks like we'll be able to move the qdisc stuff over to a new
> wiphy concept the master device is getting completely useless. Joy :)

Could you please provide details about the solution?  Maybe a link?

Here's what I would consider:

1) Accept wiphy as a network device.  This would be a rare case of
polymorphism in the kernel, which would make me feel uneasy.

2) Introduce a notion of the "secondary queue" of the device, which
would be the master queue for the virtual d80211 network devices.  This
could be extended to other virtual interfaces (e.g. VLAN).  Virtual
devices sharing the hardware would have the same secondary queue.  In
the case of VLAN, the secondary queue of one VLAN device would be the
primary queue of the physical device.

3) Have a way to create the master device on demand from wiphy or a
virtual device specifically for the purpose of manipulating its queue.

4) Introduce hidden network devices, seen by tc but not by ifconfig,
route et al.  Make the master hidden.

I wonder if you invented something better than that.

> d80211: clean up some stupid list and loop code
> d80211: reduce mdev usage
> d80211: reduce mdev usage
> d80211: reduce mdev usage, fix ieee80211_rx_mgmt
> d80211: reduce master ieee80211_ptr deref in scan routines

I think these are pretty uncontroversial, especially the loop code.  The
rest may need some wider and longer discussion (at least give driver
maintainers and the top kernel folks a chance to look at what you are
suggesting).

-- 
Regards,
Pavel Roskin


