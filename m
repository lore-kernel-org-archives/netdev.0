From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 09/11] b44: fix eeprom endianess issue
Date: Mon, 25 Sep 2006 19:59:34 -0400
Message-ID: <45186D66.1000508@garzik.org>
References: <200609252339.k8PNdNE4002654@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mb@bu3sch.de,
	Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:64471 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751775AbWIYX7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 19:59:37 -0400
To: akpm@osdl.org
In-Reply-To: <200609252339.k8PNdNE4002654@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Michael Buesch <mb@bu3sch.de>
> 
> This fixes eeprom read on big-endian architectures.
> 
> Signed-off-by: Michael Buesch <mb@bu3sch.de>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>
> ---
> 
>  drivers/net/b44.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN drivers/net/b44.c~b44-fix-eeprom-endianess-issue drivers/net/b44.c
> --- a/drivers/net/b44.c~b44-fix-eeprom-endianess-issue
> +++ a/drivers/net/b44.c
> @@ -2055,7 +2055,7 @@ static int b44_read_eeprom(struct b44 *b
>  	u16 *ptr = (u16 *) data;
>  
>  	for (i = 0; i < 128; i += 2)
> -		ptr[i / 2] = readw(bp->regs + 4096 + i);
> +		ptr[i / 2] = cpu_to_le16(readw(bp->regs + 4096 + i));

Seems highly silly to me:  readw() already swaps on big endian, so 
you're just swapping again.  And then...  read the call of 
b44_read_eeprom():  bp->dev->dev_addr[] assignment is such that it swaps 
YET AGAIN.

Seems like a better solution would be to remove the manual swap from the 
caller of b44_read_eeprom().

	Jeff



