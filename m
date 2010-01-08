From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/5] ethtool: Introduce n-tuple filter
 programming support
Date: Fri, 08 Jan 2010 00:38:33 -0800 (PST)
Message-ID: <20100108.003833.178515565.davem@davemloft.net>
References: <20100107044905.28605.54076.stgit@localhost.localdomain>
	<20100108.002342.144442434.davem@davemloft.net>
	<Pine.WNT.4.64.1001080028250.15300@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, deri@ntop.org, joseph.gasparakis@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60284
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750974Ab0AHIiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 03:38:25 -0500
In-Reply-To: <Pine.WNT.4.64.1001080028250.15300@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Fri, 8 Jan 2010 00:34:23 -0800 (Pacific Standard Time)

> Yes, I left that in there somewhat accidentally.  I had every intention in 
> putting a get routine in, but I couldn't come up with a generic way to 
> work with most hardware (how to get all filters back and dump them).  The 
> 82599 needs to query the hardware for each filter currently programmed, 
> and I'm not sure what the niu hardware layout is for the filters.

NIU simply has a TCAM array that you can read the values back from.

> I can remove the get stubs for now, since I have no good solution to dump 
> the filters that is generic.

For hardware where it's difficult to read the values back, you
can maintain a copy of the current filters in software.

Just an idea.  If you need you'll need something like this for
multiple drivers already, probably we can put the helper code
into ethtool.c and just maintain a software copy in the kernel
for all devices.  Even one's for which fetching is straightforward.

And anyways, I can't see this being a usable interface if the current
set of filters can't be queried by the user.
