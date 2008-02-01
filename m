From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 1 Feb 2008 05:35:14 +0100
Message-ID: <20080201043514.GB10720@one.firstfloor.org>
References: <20080131183735.GC4671@one.firstfloor.org> <20080131100846.00934e25@extreme> <20080131185328.GD4671@one.firstfloor.org> <47A211A0.1040502@trash.net> <20080131190125.GE4671@one.firstfloor.org> <D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com> <20080131193406.GH4671@one.firstfloor.org> <D5C1322C3E673F459512FB59E0DDC32904700F27@orsmsx414.amr.corp.intel.com> <20080131231045.GA5543@ghostprotocols.net> <D5C1322C3E673F459512FB59E0DDC3290133D2A0@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Andi Kleen <andi@firstfloor.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:45359 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756822AbYBAEAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 23:00:45 -0500
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290133D2A0@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 31, 2008 at 03:42:54PM -0800, Waskiewicz Jr, Peter P wrote:
> > Well, it could be just that when using such qdiscs TSO would be
> > disabled, but the user could override this by using ethtool after
> > loading the qdiscs.
> 
> I still disagree with this.  The qdisc should not cause anything to happen to feature flags on the device. It's the scheduling layer and really shouldn't care about what features the device supports or not.  If someone has an issue with a feature hurting performance or causing odd behavior when using a qdisc, then they should disable the feature on the device using the appropriate tools provided.  If it's the qdisc causing issues, then either the qdisc needs to be fixed, or it should be documented what features are recommended to be on and off with the qdisc.  I don't agree that the scheduling layer should affect features on an underlying device.

You seem to only look at this from a high level theoretical standpoint.

But more down to earth: do you have a useful scenario where it makes
sense to do shaping or another qdisc on GSO packets? My take is that
when you decide to do any packet scheduling you really want to do 
it on wire packets, not some internal stack implementation implementation
detail units.

-Andi
