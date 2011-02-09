From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6][2.6.38-rc2] panic during stress testing
Date: Wed, 09 Feb 2011 12:46:36 -0800 (PST)
Message-ID: <20110209.124636.189706471.davem@davemloft.net>
References: <1297189925.4087.8.camel@jbrandeb-mobl2>
	<20110208.135113.59683468.davem@davemloft.net>
	<alpine.WNT.2.00.1102081611130.5424@JBRANDEB-DESK2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.e.pieper@intel.com
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43959
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753357Ab1BIUqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 15:46:00 -0500
In-Reply-To: <alpine.WNT.2.00.1102081611130.5424@JBRANDEB-DESK2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Wed, 9 Feb 2011 10:12:03 -0800 (Pacific Standard Time)

> neigh appears to be zero? since the check just above in dst_destroy was 
> checking it against NULL already, maybe we have a race, with some other 
> free of neigh (assigned from dst->neighbor)
> 
> This is quickly getting beyond me, I tried to check for some changes 
> around dst->neighbor but didn't see anything recent.

"neigh" is non-zero, however it is freed memory and thus unmapped by
the "use after free" debugging code.

That's why it OOPS's.
