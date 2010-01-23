From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: NETDEV WATCHDOG should print something every
 time
Date: Fri, 22 Jan 2010 18:45:28 -0800 (PST)
Message-ID: <20100122.184528.55590107.davem@davemloft.net>
References: <20100122214333.14389.86017.stgit@jbrandeb-ich9b.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57171
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751976Ab0AWCpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 21:45:17 -0500
In-Reply-To: <20100122214333.14389.86017.stgit@jbrandeb-ich9b.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Fri, 22 Jan 2010 13:43:33 -0800

> commit 5337407c changed NETDEV WATCHDOG messages into a message
> that will only print once per driver load.  This removed a significant amount
> of information from an admin who might be missing that his system was having
> NETDEV WATCHDOGs, esp since there is no other global counter available to
> count these events.

It's not once per driver load, it's once globally.

Once per driver load would be in fact what I would actually
consider more reasonable, so put the boolean state into
struct netdev, and test it to decide whether to do the
WARN_ON() print.

Doing a message every time is way overboard and is going to
spam some people's systems to the point where they can't
even diagnose the problem, so I'm not accepting a patch
which does that.
