From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.18 3/6] bnx2: Use CPU native page size
Date: Mon, 12 Jun 2006 22:20:36 -0700 (PDT)
Message-ID: <20060612.222036.15588314.davem@davemloft.net>
References: <1150157833.26173.8.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36824
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932888AbWFMFUZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 01:20:25 -0400
To: mchan@broadcom.com
In-Reply-To: <1150157833.26173.8.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 12 Jun 2006 17:17:13 -0700

> Use CPU native page size to determine various ring sizes. This allows
> order-0 memory allocations on all systems.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Are you sure you want to do this when the base page size is up to 64K
on some IA64/PowerPC64/Sparc64 configurations?

Maybe you can use a limit with some ifdef tests, something like:

#if PAGE_SHIFT > 13
#define BCM_PAGE_BITS 13
#else
#define BCM_PAGE_BITS PAGE_SHIFT
#endif

which would limit it to 8K.
