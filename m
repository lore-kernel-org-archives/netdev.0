From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] [NET]: Allow netdev REGISTER/CHANGENAME events to
 fail
Date: Mon, 30 Jul 2007 17:03:57 -0700 (PDT)
Message-ID: <20070730.170357.44097637.davem@davemloft.net>
References: <20070726090725.GA510@gondor.apana.org.au>
	<E1IDzLk-0000AI-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53655
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753933AbXGaAEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 20:04:06 -0400
In-Reply-To: <E1IDzLk-0000AI-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 26 Jul 2007 17:09:36 +0800

> [NET]: Allow netdev REGISTER/CHANGENAME events to fail
> 
> This patch adds code to allow errors to be passed up from event
> handlers of NETDEV_REGISTER and NETDEV_CHANGENAME.  It also adds
> the notifier_from_errno/notifier_to_errnor helpers to pass the
> errno value up to the notifier caller.
> 
> If an error is detected when a device is registered, it causes
> that operation to fail.  A NETDEV_UNREGISTER will be sent to
> all event handlers.
> 
> Similarly if NETDEV_CHANGENAME fails the original name is restored
> and a new NETDEV_CHANGENAME event is sent.
> 
> As such all event handlers must be idempotent with respect to
> these events.
> 
> When an event handler is registered NETDEV_REGISTER events are
> sent for all devices currently registered.  Should any of them
> fail, we will send NETDEV_GOING_DOWN/NETDEV_DOWN/NETDEV_UNREGISTER
> events to that handler for the devices which have already been
> registered with it.  The handler registration itself will fail.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.

Interesting encoding scheme :-)
