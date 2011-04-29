From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Module use count must be updated as bridges
 are created/destroyed
Date: Fri, 29 Apr 2011 00:25:30 -0700 (PDT)
Message-ID: <20110429.002530.112581952.davem@davemloft.net>
References: <4DBA830A020000780003ED5D@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	jeffm@suse.com, netdev@vger.kernel.org
To: JBeulich@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34076
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754475Ab1D2H0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 03:26:04 -0400
In-Reply-To: <4DBA830A020000780003ED5D@vpn.id2.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan Beulich" <JBeulich@novell.com>
Date: Fri, 29 Apr 2011 08:21:14 +0100

> Otherwise 'modprobe -r' on a module having a dependency on bridge will
> implicitly unload bridge, bringing down all connectivity that was using
> bridges.
> 
> Signed-off-by: Jan Beulich <jbeulich@novell.com>
> Cc: Jeff Mahoney <jeffm@suse.com>

All network device drivers behave exactly the same way, when you rmmod
the thing we unconfigure all the routes, addresses, etc. going through
that device and let you unload it.

And this behavior is very much intentional.

Don't add an exception here.

