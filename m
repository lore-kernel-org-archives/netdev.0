From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.23-rc4-mm1: e1000e napi lockup
Date: Fri, 07 Sep 2007 01:03:38 -0700 (PDT)
Message-ID: <20070907.010338.41638771.davem@davemloft.net>
References: <46E0FB82.2040000@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, auke-jan.h.kok@intel.com
To: jirislaby@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:49927
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S964960AbXIGIDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2007 04:03:46 -0400
In-Reply-To: <46E0FB82.2040000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jirislaby@gmail.com>
Date: Fri, 07 Sep 2007 09:19:30 +0200

> I found a regression in 2.6.23-rc4-mm1 (since -rc3-mm1) in e1000e driver.
> napi_disable(&adapter->napi) in e1000_probe freezes the kernel on boot.

Yes, the semantics changed slightly in the net-2.6.24 tree the
other week and someone needs to fix it up.

The netif_napi_add() implicitly does a napi_disable() call.  Device
open must explicitly napi_enable() and device close must explicitly
napi_disable(), and if done elsewhere these calls must be strictly
balanced.
