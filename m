From: David Miller <davem@davemloft.net>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Tue, 04 Dec 2007 22:06:34 -0800 (PST)
Message-ID: <20071204.220634.112782343.davem@davemloft.net>
References: <4755A21F.2020407@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: simon@fire.lp0.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49254
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750969AbXLEGGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 01:06:35 -0500
In-Reply-To: <4755A21F.2020407@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Arlott <simon@fire.lp0.eu>
Date: Tue, 04 Dec 2007 18:53:19 +0000

> If I have a IPsec rule like:
> 	spdadd 192.168.7.8 1.2.3.4 any -P out ipsec esp/transport//require;
> (i.e. a remote host 1.2.3.4 which will not respond)
> 
> Then any attempt to communicate with 1.2.3.4 will block, even when using non-blocking sockets:

If you don't like this behavior:

	echo "1" >/proc/sys/net/core/xfrm_larval_drop

but those initial connection setup packets will be dropped while
waiting for the IPSEC route to be resolved, and in your 8 hour case
the TCP connect will fail.

Anyways, the choice for different behavior is there, select it
to suit your tastes.
