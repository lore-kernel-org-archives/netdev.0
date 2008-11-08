From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] net: fix /proc/net/snmp as memory corruptor
Date: Sat, 8 Nov 2008 13:05:12 -0800
Message-ID: <OF3DE3524D.66B1A705-ON882574FB.00729B02-882574FB.0073D449@us.ibm.com>
References: <4915FAAC.1010905@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Alexey Dobriyan <adobriyan@gmail.com>, alan@lxorguk.ukuu.org.uk,
	davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Eric Sesterhenn <snakebyte@gmx.de>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:50242 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245AbYKHVFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2008 16:05:15 -0500
In-Reply-To: <4915FAAC.1010905@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> If you are not sure what I am talking about, then you should probably
> not use static variables at all. I found this fix quite obvious...

        Actually, I didn't realize "out" was static -- was looking at just
the patch, and obviously missing your point.
        I don't have a problem with 16 ints on the stack (or shorts, as
you pointed out)-- I didn't want the data on the stack, which may be
64-bit ints. In your patch, you're collecting all of it on the stack
(doubling its size).
        If there is no interlocking at a higher layer (and I haven't 
looked
at this in a long time...) (ie, exclusive opens), then I agree, it
shouldn't be static.

        Why not just that? (ie, add count=0 as Alexey did and remove the
static qualifier from "out")

                                +-DLS

