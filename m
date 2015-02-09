From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: silence sparse endianness warnings in
 checksums
Date: Sun, 08 Feb 2015 16:30:01 -0800 (PST)
Message-ID: <20150208.163001.1517021094146035035.davem@davemloft.net>
References: <1423233832-8229-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, therbert@google.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34398 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753071AbbBIAaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 19:30:02 -0500
In-Reply-To: <1423233832-8229-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri,  6 Feb 2015 15:43:52 +0100

> In __skb_checksum_validate_complete and its callers, we only test that
> the return value is non-zero, so it's safe to __force the type.
> 
> Callers of gso_make_checksum pass a __sum16, use that.
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

I don't like this, you're just moving the casts from one place to
another.

These functions are a mess, they are combining one thing (returning
the final csum value) with another thing (non-zero return has some
boolean meaning).

These issues should be explicitly accomodated rather than papered
around.
