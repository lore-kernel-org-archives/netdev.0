From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 10:47:05 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com>
References: <20080131124632.GA25299@basil.nowhere.org> <20080131092327.75b9c369@extreme> <20080131183322.GA4671@one.firstfloor.org> <47A20CDC.5090104@trash.net> <20080131183735.GC4671@one.firstfloor.org> <20080131100846.00934e25@extreme> <20080131185328.GD4671@one.firstfloor.org> <47A211A0.1040502@trash.net> <20080131190125.GE4671@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>
To: "Andi Kleen" <andi@firstfloor.org>,
	"Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:58324 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759127AbYAaSvo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:51:44 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080131190125.GE4671@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> My point was that without TSO different submitters will 
> interleave their streams (because they compete about the 
> qdisc submission) and then you end up with a smooth rate over 
> time for all of them.
> 
> If you submit in large chunks only (as TSO does) it will 
> always be more bursty and that works against the TBF goal.
> 
> For a single submitter you would be correct.
> 
> -Andi

TSO by nature is bursty.  But disabling TSO without the option of having
it on or off to me seems to aggressive.  If someone is using a qdisc
that TSO is interfering with the effectiveness of the traffic shaping,
then they should turn off TSO via ethtool on the target device.  Some
people may want TSO with certain rate limiter settings.  That way (as
Stephen said) you can even allow the stack to GSO, then segment before
calling hard_start_xmit(), which still saves a number of cycles.

I'd rather not see this, but a documented recommendation why TSO could
be bad for some traffic shaping qdiscs.  Give the power to the user to
either shoot themselves in the foot or disable TSO when needed.

-PJ Waskiewicz
<peter.p.waskiewicz.jr@intel.com>
