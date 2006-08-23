From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] b44: fix eeprom endianess issue
Date: Wed, 23 Aug 2006 12:38:49 +0200
Message-ID: <200608231238.49783.mb@bu3sch.de>
References: <200608231232.05750.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org, davem@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:28308
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S964827AbWHWKjT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 06:39:19 -0400
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jeff@garzik.org>
In-Reply-To: <200608231232.05750.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oh, I think I should have CCed Jeff ;)
Sorry.

On Wednesday 23 August 2006 12:32, Michael Buesch wrote:
> Hi Andrew,
> 
> Please apply this patch to -mm for testing.
> I think in the long term we want to convert b44 to use the
> new ssb backend driver, which would also fix the issue, but
> for now I think this small fix is best.
> 
> Please note that this test is only compile tested, as
> I don't have a b44 device.
> 
> --
> 
> This fixes eeprom read on big-endian architectures.
> 
> Signed-off-by: Michael Buesch <mb@bu3sch.de>
> 
> Index: linux-2.6/drivers/net/b44.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/b44.c	2006-08-22 11:27:56.000000000 +0200
> +++ linux-2.6/drivers/net/b44.c	2006-08-23 12:26:31.000000000 +0200
> @@ -2055,7 +2055,7 @@
>  	u16 *ptr = (u16 *) data;
>  
>  	for (i = 0; i < 128; i += 2)
> -		ptr[i / 2] = readw(bp->regs + 4096 + i);
> +		ptr[i / 2] = cpu_to_le16(readw(bp->regs + 4096 + i));
>  
>  	return 0;
>  }
> 
> 

-- 
Greetings Michael.
