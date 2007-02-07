From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] tg3 : avoid an expensive divide
Date: 07 Feb 2007 10:54:49 +0100
Message-ID: <p73ireemgwm.fsf@bingen.suse.de>
References: <200702061536.18800@nienna>
	<20070206.114659.107250775.davem@davemloft.net>
	<45C8EAC4.9020803@cosmosbay.com>
	<20070206.131908.13769204.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, mchan@broadcom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:52029 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030565AbXBGIya (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 03:54:30 -0500
In-Reply-To: <20070206.131908.13769204.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> 
> Because I've seen gcc optimize this properly before (at least on
> sparc64), it means that either:
> 
> 1) There is a GCC bug where the properties of the constants
>    do not propagate.
> 
> 2) GCC really thinks the divide is cheaper (code density vs.
>    cycle count tradeoffs etc.)

Probably Eric compiled with the now default CONFIG_CC_OPTIMIZE_FOR_SIZE/-Os.
With that gcc decides to use the shorter hardware divide instruction, even
though it is significantly slower than an expanded optimized sequence
for constant dividend.

We've seen this in a few other cases while during performance regression
testing between kernels that still used -O2 vs the newer -Os.

No good solution found unfortunately.

-Andi
