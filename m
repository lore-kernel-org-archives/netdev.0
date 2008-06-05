From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] NET: DCB generic netlink interface
Date: Thu, 5 Jun 2008 22:29:53 +0200
Message-ID: <20080605202953.GN20815@postel.suug.ch>
References: <20080527141339.12851.98781.stgit@localhost.localdomain> <20080604.114456.32717312.davem@davemloft.net> <D5C1322C3E673F459512FB59E0DDC32905348FD4@orsmsx414.amr.corp.intel.com> <20080605.074324.38999631.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peter.p.waskiewicz.jr@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:60038 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751466AbYFEU3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 16:29:33 -0400
Content-Disposition: inline
In-Reply-To: <20080605.074324.38999631.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller <davem@davemloft.net> 2008-06-05 07:43
> From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
> Date: Wed, 4 Jun 2008 23:23:00 -0700
> 
> > I'm not sure I follow this.  DCB is a scheduling policy, but that
> > scheduling policy is in the hardware.  The configuration interface,
> > which is what this is, happens out of band of any scheduling policies in
> > the kernel.  It's very analogous to the wireless configuration layer for
> > mac80211 that uses generic netlink.
> 
> And I'm saying we should have a equivalent software scheduler in
> the kernel that can implement this if the hardware offloaded version
> isn't present.

I agree, I think we should make it possible to use DCB without the strict
need for hardware support. Our current classful qdiscs htb and cbq already
fullfil the requirements of priority grouping as specified in 802.1.qaz
except that the configuration interface is different as it does not use
percentage values.

There is also demand for a networking cgroup subsystem which requires
exactly the same kind of priority grouping. It would be only logical
to be able to use hardware support where possible.

Therefore I believe the way to go is to build a new or extend the
current tc system. Like with the current default qdisc, it should be
possible to automatically create qdiscs for DCB or cgroup while still
allowing to overwrite the tc configuration with a custom tree for

As Patrick pointed out, this probably belongs in the rtnetlink family as
it will be strictly attached to the net_device.
