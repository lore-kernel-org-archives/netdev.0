From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: 21 Sep 2007 20:01:23 +0200
Message-ID: <ygfzlzfuccs.fsf@janus.isnogud.escape.de>
References: <20070920184323.3795.0@janus.isnogud.escape.de>
	<20070920184532.3795.2@janus.isnogud.escape.de>
	<46F3BD75.6010904@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:36063 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761468AbXIUSFq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 14:05:46 -0400
In-Reply-To: <46F3BD75.6010904@trash.net>; from Patrick McHardy on Fri, 21 Sep 2007 14:47:49 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> You drop the module reference again when leaving this function.
> So sock->ops might contain a stale pointer if the module is
> unloaded after this. You need to either keep the module reference
> while the socket is alive or remove stale references when
> unregistering the protocol.

I don't think that can happen.  Before we drop the module reference we
call sk_alloc() which gets another module reference via its cp->prot
argument.  If sk_alloc() fails we return with error from can_create()
I assume sock->ops won't be used after that.

urs
