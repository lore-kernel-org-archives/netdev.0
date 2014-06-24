From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] net: systemport: fix UniMAC reset logic
Date: Tue, 24 Jun 2014 16:12:41 -0700 (PDT)
Message-ID: <20140624.161241.1533958645479291631.davem@davemloft.net>
References: <1403294500-31905-1-git-send-email-f.fainelli@gmail.com>
	<1403294500-31905-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55020 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855AbaFXXMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 19:12:42 -0400
In-Reply-To: <1403294500-31905-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 20 Jun 2014 13:01:40 -0700

> The UniMAC CMD_SW_RESET bit is not a self-clearing bit, so we need to
> assert it, wait a bit and clear it manually. As a result, umac_reset()
> is updated not to return any value.
> 
> By setting CMD_SW_RESET and only that bit, we were also clearing the
> other 31 bits, overriding the hardware reset defaults which are
> correctly set on purpose.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

I agree with Sergei, this is really suspicious that the existing code
never wrote the sw reset bit into the register at all, it just writes
a zero.

And you don't mention this at all in this commit message.

If I were to guess, I would fathom that the sequence was partially
copied from the other broadcom driver, the genet one.  There it
issues CMD_SW_RESET by first clearing the entire regiser to zero,
then writing CMD_SW_RESET, and then polling for that bit to clear.

I'm assuming that is being done for a good reason, and I'd like
you to make sure that same reason does not apply here.

Thanks.
