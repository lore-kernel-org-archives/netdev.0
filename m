From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 1 Feb 2008 01:37:59 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC32904737A42@orsmsx414.amr.corp.intel.com>
References: <20080131183322.GA4671@one.firstfloor.org> <47A20CDC.5090104@trash.net> <20080131183735.GC4671@one.firstfloor.org> <20080131100846.00934e25@extreme> <20080131185328.GD4671@one.firstfloor.org> <47A211A0.1040502@trash.net> <20080131190125.GE4671@one.firstfloor.org> <D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com> <20080131193406.GH4671@one.firstfloor.org> <1201847738.17656.5.camel@roma.44ansell.gdt.id.au> <20080201074600.GA12644@one.firstfloor.org> <47A2C985.30409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Glen Turner" <gdt@gdt.id.au>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>,
	"Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:6514 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755437AbYBAJvB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 04:51:01 -0500
Content-class: urn:content-classes:message
In-Reply-To: <47A2C985.30409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Indeed. As an example of an unknowing user, this discussion 
> made me check whether my cablemodem device (on which I'm 
> using HFSC) uses TSO :)

The TSO defer logic is based on your congestion window and current
window size.  So the actual frame sizes hitting your NIC attached to
your DSL probably aren't anywhere near 64KB, but probably more in line
with whatever your window size is for DSL.

The bottom line is TSO saves CPU cycles.  If we want to make it go away
because of a traffic shaping qdisc interfering, then that's fine.  I
just don't think a TSO option should be added to the scheduler layer,
since it already exists in the ethtool layer.  Asking a user to type
'ethtool -k <devicename> tso off' is probably going to be much easier
than setting an option on your qdisc through tc to turn TSO back on.

I think we're having more of a disagreement of what is considered the
"normal case" user.  If you are on a slow link, such as a DSL/cable
line, your TCP window/congestion window aren't going to be big enough to
generate large TSO's, so what is the issue?  But disabling TSO, say on a
10 GbE link, can cut throughput by half (I have data on 8-core machines
with 10 GbE with/without TSO if you're interested).  Even on a
single-core machine with a 1GbE link can have bad performance hits.  So
this is why I'm so concerned about a proposal to turn off TSO outside of
the current established methods of using ethtool.  Rather than educating
the user about how to turn TSO back on using tc if they want it, educate
them why they may want to consider turning TSO off in certain
configurations.  And I don't consider any user effectively using a TBF
qdisc someone incapable of understanding how to use ethtool.

Cheers,

-PJ Waskiewicz
