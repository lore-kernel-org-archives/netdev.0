From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][ATM]: Do not free already unregistered net device.
Date: Mon, 05 May 2008 12:37:03 -0700 (PDT)
Message-ID: <20080505.123703.257416714.davem@davemloft.net>
References: <1210005880.5716.4.camel@Linux.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@openvz.org
To: pcnet32@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35455
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752073AbYEEThD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 15:37:03 -0400
In-Reply-To: <1210005880.5716.4.camel@Linux.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Fry <pcnet32@verizon.net>
Date: Mon, 05 May 2008 09:44:40 -0700

> I do not understand why this change was accepted.  All of the network
> drivers I just looked at in 2.6.25 do unregister_netdev() followed
> sometime soon by free_netdev().  Is there something different about ATM
> devices?  I did not look at all the drivers.

Indeed, this change does look bogus.

Pavel, please take a look, unregister_netdev() indeed does not free
the netdevice, and something (usually the caller) needs to do it.

I think I should revert your change.
