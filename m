From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.18 4/6] bnx2: Add firmware decompression
Date: Mon, 12 Jun 2006 17:38:02 -0700 (PDT)
Message-ID: <20060612.173802.52167155.davem@davemloft.net>
References: <1150157838.26173.9.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54727
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932705AbWFMAhw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 20:37:52 -0400
To: mchan@broadcom.com
In-Reply-To: <1150157838.26173.9.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 12 Jun 2006 17:17:18 -0700

> Add functions to decompress firmware before loading to the internal
> CPUs. Compressing the firmware reduces the driver size significantly.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
 ...
> +#define FNAME	0x8
> +	if (zbuf[3] & FNAME)
> +		while (zbuf[n++] != 0);

This can potentially loop past the end of zbuf[], so maybe
put a sanity check against 'len' and return non-zero if we
traverse past the end?


