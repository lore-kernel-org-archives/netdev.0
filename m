From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] llc: dont trust payload size on test cmd
Date: Tue, 26 Feb 2008 17:51:40 -0800 (PST)
Message-ID: <20080226.175140.187595682.davem@davemloft.net>
References: <20080225161439.GZ84358@surrealistic.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net
To: jwestfall@surrealistic.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36482
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751914AbYB0Buz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 20:50:55 -0500
In-Reply-To: <20080225161439.GZ84358@surrealistic.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Westfall <jwestfall@surrealistic.net>
Date: Mon, 25 Feb 2008 08:14:39 -0800

> In testing its not safe to trust the payload length we are given in a
> received llc test command header.  Instead we should calculate this 
> ourselves or run the risk of an skb_over_panic() if the received length in 
> the header is > then the actual payload size.
> 
> Signed-off-by: Jim Westfall <jwestfall@surrealistic.net>

I think we should, rather, use the value given to us in the
proto field, but validate it against the real packet length.

If it's found to be bogus, we should drop the packet.
