From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/4]: Revamp TX hashing.
Date: Tue, 27 Jan 2009 16:40:24 -0800 (PST)
Message-ID: <20090127.164024.141230513.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43815
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750988AbZA1Ak1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 19:40:27 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id ADAA435C003
	for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 16:40:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The simple_tx_hash() function we currently have in
net/core/dev.c is very rudimental and doesn't handle
routing and firewall scenerios very well.

The next 4 patches attempt to cure that.  The end result
is:

1) The RX queue selection of the input device seeds the
   TX queue selection for that SKB.

2) Locally generated packets seed the TX queue using
   skb->sk->sk_hash

Then we kill off the by-hand hashing code since in all cases
that matter it is no longer necessary.

Protocols that fail to store a proper sk->sk_hash value will
need to be fixed up to do so.  I encourage anyone so motivated
to do that audit :-)
