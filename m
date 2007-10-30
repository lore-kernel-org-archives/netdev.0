From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] pegasos_eth.c: Fix compile error over MV643XX_ defines
Date: Tue, 30 Oct 2007 14:32:55 -0400
Message-ID: <472778D7.6050805@garzik.org>
References: <20071029212729.GA4074@pogo> <20071029223900.GA7097@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Tzachi Perelstein <tzachi@marvell.com>
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60775 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756336AbXJ3SdC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 14:33:02 -0400
In-Reply-To: <20071029223900.GA7097@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dale Farnsworth wrote:
> On Mon, Oct 29, 2007 at 05:27:29PM -0400, Luis R. Rodriguez wrote:
>> This commit made an incorrect assumption:
>> --
>> Author: Lennert Buytenhek <buytenh@wantstofly.org>
>>  Date:   Fri Oct 19 04:10:10 2007 +0200
>>
>>     mv643xx_eth: Move ethernet register definitions into private header
>>     
>>     Move the mv643xx's ethernet-related register definitions from
>>     include/linux/mv643xx.h into drivers/net/mv643xx_eth.h, since
>>     they aren't of any use outside the ethernet driver.
>>     
>>     Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
>>     Acked-by: Tzachi Perelstein <tzachi@marvell.com>
>>     Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
>> --
>>
>> arch/powerpc/platforms/chrp/pegasos_eth.c made use of a 3 defines there.
>>
>> mcgrof@pogo:~/devel/wireless-2.6$ git-describe 
>>
>> v2.6.24-rc1-138-g0119130
>>
>> This patch fixes this by internalizing 3 defines onto pegasos which are
>> simply no longer available elsewhere. Without this your compile will fail
> 
> That compile failure was fixed in commit
> 30e69bf4cce16d4c2dcfd629a60fcd8e1aba9fee by Al Viro.
> 
> However, as I examine that commit, I see that it defines offsets from
> the eth block in the chip, rather than the full chip registeri block
> as the Pegasos 2 code expects.  So, I think it fixes the compile
> failure, but leaves the Pegasos 2 broken.
> 
> Luis, do you have Pegasos 2 hardware?  Can you (or anyone) verify that
> the following patch is needed for the Pegasos 2?
> 
> Thanks,
> -Dale
> 
> ---------------------------------
> 
> mv643xx_eth: Fix MV643XX_ETH offsets used by Pegasos 2
> 
> In the mv643xx_eth driver, we now use offsets from the ethernet
> register block within the chip, but the pegasos 2 platform still
> needs offsets from the full chip's register base address.
> 
> Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
> ---
>  include/linux/mv643xx_eth.h |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
> index 8df230a..30e11aa 100644
> --- a/include/linux/mv643xx_eth.h
> +++ b/include/linux/mv643xx_eth.h
> @@ -8,9 +8,9 @@
>  #define MV643XX_ETH_NAME		"mv643xx_eth"
>  #define MV643XX_ETH_SHARED_REGS		0x2000
>  #define MV643XX_ETH_SHARED_REGS_SIZE	0x2000
> -#define MV643XX_ETH_BAR_4	0x220
> -#define MV643XX_ETH_SIZE_REG_4	0x224
> -#define MV643XX_ETH_BASE_ADDR_ENABLE_REG	0x0290
> +#define MV643XX_ETH_BAR_4		0x2220
> +#define MV643XX_ETH_SIZE_REG_4		0x2224
> +#define MV643XX_ETH_BASE_ADDR_ENABLE_REG	0x2290

applied


