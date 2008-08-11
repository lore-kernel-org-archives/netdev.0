From: David Miller <davem@davemloft.net>
Subject: Re: LRO restructuring?
Date: Mon, 11 Aug 2008 14:03:51 -0700 (PDT)
Message-ID: <20080811.140351.54834488.davem@davemloft.net>
References: <48A03EF9.9090602@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org, brice@myri.com
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50815
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753100AbYHKVDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 17:03:51 -0400
In-Reply-To: <48A03EF9.9090602@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Mon, 11 Aug 2008 09:30:33 -0400

> Last, have you considered simply allowing "inexact" forwarding, where
> the ingress NIC is doing LRO and the egress nic is doing TSO?  You
> loose exact framing information (eg, what you emit might not be framed
> exactly as you receive it), but you can still do filtering, and the
> host overhead is very low.

Intermediate nodes are not supposed to change the transport layer
checksum if at all possible, especially on routers.

Otherwise it is much more difficult to diagnose checksum errors,
and figure out what caused such an error.

When the router doesn't modify the checksum, we know it's an end-node.
Even a firewall only "adjusts" checksums based upon packet
modifications for NAT and such, which will preserve end-node created
errors.

So no this isn't really an option.

This is why Herbert wants to preserve the original headers,
we're not supposed to change them.
