From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: reset ct before calling ndo_start_xmit
Date: Tue, 24 Jan 2017 11:21:37 -0500 (EST)
Message-ID: <20170124.112137.997945919072068039.davem@davemloft.net>
References: <e33476125bdaf4619c221aa82c034831bbdce89b.1485250657.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org, fw@strlen.de
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48560 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750740AbdAXQVj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 11:21:39 -0500
In-Reply-To: <e33476125bdaf4619c221aa82c034831bbdce89b.1485250657.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Tue, 24 Jan 2017 10:40:13 +0100

> Some devices (e.g. ipoib and most wifi drivers) can retain the
> to-be-xmitted packets on some internal queue for a possibly
> unlimited time.

This is really not legal, such behavior also potentially holds onto
sockets forever.

If driver really wants to hold onto an SKB potentially forever, it
must release these resources.

This belongs in the driver that violates, and I strongly say
"violates", the basic fundamental rules of TX handling in the stack.
Drivers absolutely must liberate queued TX packets in a reasonable,
finite, amount of time.
