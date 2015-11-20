From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tulip: turn compile-time warning into dev_warn()
Date: Fri, 20 Nov 2015 11:03:14 -0500 (EST)
Message-ID: <20151120.110314.213434169745300737.davem@davemloft.net>
References: <9720627.53btSdPcQU@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, will.deacon@arm.com,
	ard.biesheuvel@linaro.org, grundler@parisc-linux.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014AbbKTQDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 11:03:16 -0500
In-Reply-To: <9720627.53btSdPcQU@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 19 Nov 2015 11:42:26 +0100

> The tulip driver causes annoying build-time warnings for allmodconfig
> builds for all recent architectures:
> 
> dec/tulip/winbond-840.c:910:2: warning: #warning Processor architecture undefined
> dec/tulip/tulip_core.c:101:2: warning: #warning Processor architecture undefined!
> 
> This is the last remaining warning for arm64, and I'd like to get rid of
> it. We don't really know the cache line size, architecturally it would
> be at least 16 bytes, but all implementations I found have 64 or 128
> bytes. Configuring tulip for 32-byte lines as we do on ARM32 seems to
> be the safe but slow default, and nobody who cares about performance these
> days would use a tulip chip anyway, so we can just use that.
> 
> To save the next person the job of trying to find out what this is for
> and picking a default for their architecture just to kill off the warning,
> I'm now removing the preprocessor #warning and turning it into a pr_warn
> or dev_warn that prints the equivalent information when the driver gets
> loaded.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Seems reasonable, applied, thanks Arnd!
