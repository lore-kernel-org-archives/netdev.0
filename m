From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] net: fix /proc/net/snmp as memory corruptor
Date: Sat, 8 Nov 2008 11:53:09 -0800
Message-ID: <OF6C282093.F9856B9A-ON882574FB.006C580F-882574FB.006D3BF5@us.ibm.com>
References: <4915295B.4050102@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Alexey Dobriyan <adobriyan@gmail.com>, alan@lxorguk.ukuu.org.uk,
	davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Eric Sesterhenn <snakebyte@gmx.de>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:40925 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbYKHTxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2008 14:53:13 -0500
In-Reply-To: <4915295B.4050102@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oh, that was me! Thank you, Alexey!

> This should be fixed as well, or multiple threads reading /proc/net/snmp
> could get mixed results without proper locking.

I don't believe locking is an issue here. If the values
change between the first and second tests, being counters,
they are still nonzero. If they are different in different
threads, it reflects an actual change in the counter. So
I'm not sure what you're talking about here.

I don't think they should be on the stack (obviously, or
I wouldn't have written it this way). So, FWIW, I like
Alexey's fix, which is what the code should've been.

For Alexey's patch:

Acked-by: David L Stevens <dlstevens@us.ibm.com>

                                                +-DLS

