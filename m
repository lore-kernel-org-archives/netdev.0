From: David Miller <davem@davemloft.net>
Subject: Re: Question on TSO maximum segment sizes.
Date: Thu, 11 Oct 2007 17:02:44 -0700 (PDT)
Message-ID: <20071011.170244.32082446.davem@davemloft.net>
References: <D5C1322C3E673F459512FB59E0DDC32903C4407B@orsmsx414.amr.corp.intel.com>
	<20071011.163737.36654032.davem@davemloft.net>
	<470EB6D6.9020704@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58201
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752863AbXJLACm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 20:02:42 -0400
In-Reply-To: <470EB6D6.9020704@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 11 Oct 2007 16:50:46 -0700

> For just messing about, might it be possible to tweak the socket buffer sizes 
> and tcp_tso_win_divisor to kludge things for a short while?  Couldn't ship that 
> way certainly, but assuming Peter's going to get his broken hardware fixed it 
> might let him limp along until then.

TCP dynamically grows the socket buffer sizes unless the application
explicitly sets them via setsockopt() and the limits imposed in those
cases are controlled by tcp_{,r,w}mem[] sysctls.  Decreasing those
will kill performance exactly for the cases this person cares about.

No, the only way to deal with this is to GSO segment incoming frames
inside of the driver when they exceed the HW limits.
