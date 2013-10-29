From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] 3c515: Fix warning when building
Date: Tue, 29 Oct 2013 00:03:16 -0400 (EDT)
Message-ID: <20131029.000316.767189982282205506.davem@davemloft.net>
References: <1382738386-29888-1-git-send-email-ricec2@rpi.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ricec2@rpi.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980Ab3J2EDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 00:03:20 -0400
In-Reply-To: <1382738386-29888-1-git-send-email-ricec2@rpi.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Rice <ricec2@rpi.edu>
Date: Fri, 25 Oct 2013 21:59:46 +0000

> -		outl((int) (skb->data), ioaddr + Wn7_MasterAddr);
> +		outl((size_t) (skb->data), ioaddr + Wn7_MasterAddr);

outl() takes an "int" not a "size_t".   You're avoiding the warning,
but on 64-bit, for example, you're silently allowing the compiler
to accept chopping off the top 32-bits of the 64-bit pointer address
off.

The warning is valid, this code won't work in certain environments,
and killing the warning is just papering over the problem such that
it will never get addressed properly.

I'm not applying patches like this, sorry.
