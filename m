From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: dummy: add auto_up module parameter
Date: Mon, 06 Dec 2010 12:36:46 -0800 (PST)
Message-ID: <20101206.123646.183042768.davem@davemloft.net>
References: <1291132647-15018-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddvlad@rosedu.org,
	lucian.grijincu@gmail.com
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54041
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753172Ab0LFUgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 15:36:20 -0500
In-Reply-To: <1291132647-15018-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Tue, 30 Nov 2010 17:57:27 +0200

> Add auto_up module parameter to automatically bring up the created
> devices. This is useful when using the dummy driver for testing net
> device register / unregister performance.
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

Registering a new netdevice with IFF_UP set is an error.  You can't
set IFF_UP without also doing all of the other work, callbacks, and
state changes which are made by dev_open()'s code paths.

If, as you say, your interests are in testing register/unregister
performance, you can do that by making the appropriate calls in a loop
from userspace.

I honestly don't see what you hope to gain with this change, and
anyways since the registration state is basically illegal you'll need
to find another way to do this.
