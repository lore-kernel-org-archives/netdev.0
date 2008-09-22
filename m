From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Sun, 21 Sep 2008 21:27:24 -0700 (PDT)
Message-ID: <20080921.212724.193719407.davem@davemloft.net>
References: <20080922010834.GB3059@2ka.mipt.ru>
	<20080921.190715.144340989.davem@davemloft.net>
	<20080922041929.GA20165@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johaahn@gmail.com, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33350
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750899AbYIVE1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 00:27:36 -0400
In-Reply-To: <20080922041929.GA20165@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Mon, 22 Sep 2008 08:19:29 +0400

> Stream socket means that whatever data we put to it, it will become
> completely boundary-free, in that regard, that receiving side will not
> be able to get original sending packet sizes (without too much efforts).

Right.

> Datagram just preservs the boundaries and that's what we have with this
> patch.

Not exactly.

Each and every send() operation on a datagram socket must result in
exactly one packet.  sendfile() was following this rule, when it
returned successfully only one single packet was emitted.

The new sendfile() semantics are outside of this model.
