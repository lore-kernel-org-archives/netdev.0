From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4/arp.c: Fix arp reply when sender ip 0
Date: Thu, 15 Nov 2007 15:28:13 -0800 (PST)
Message-ID: <20071115.152813.89410917.davem@davemloft.net>
References: <cac0ab7d0711150340p58eda94ah92894072ba328205@mail.gmail.com>
	<20071115154032.GA30391@ms2.inr.ac.ru>
	<cac0ab7d0711151340l1cc91a2dw5ebf36e166d16d7a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
	jmorris@namei.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: the.sator@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56513
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755180AbXKOX2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 18:28:14 -0500
In-Reply-To: <cac0ab7d0711151340l1cc91a2dw5ebf36e166d16d7a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jonas Danielsson" <the.sator@gmail.com>
Date: Thu, 15 Nov 2007 22:40:13 +0100

> Is there a reason that the target hardware address isn't the target
> hardware address?

Linux subscribes to the host based addressing model rather
than an interface based addressing model.  Both approaches
are valid by RFCs.

Because of this, in cases where a choice can be made Linux will
advertise what is most likely to result in successful communication.

This is likely why we are changing that target address to the one of
the interface actually sending back the reply rather than the zero
value you used.

In fact I think this information can be useful to the sender of
the DAD request.
