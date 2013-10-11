From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH 14/14] net: smc91x: dont't use SMC_outw for fixing up
 halfword-aligned data
Date: Fri, 11 Oct 2013 16:41:57 -0400 (EDT)
Message-ID: <alpine.LFD.2.03.1310111634010.3023@syhkavp.arg>
References: <1381499540-28794-1-git-send-email-matthew.leach@arm.com> <1381499540-28794-15-git-send-email-matthew.leach@arm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-arm-kernel@lists.infradead.org, ankit.jindal@linaro.org,
	steve.mcintyre@linaro.org, tushar.jagad@linaro.org,
	will.deacon@arm.com, catalin.marinas@arm.com,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Matthew Leach <matthew.leach@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:35983 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758842Ab3JKUmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 16:42:00 -0400
Received: by mail-qa0-f44.google.com with SMTP id cm18so1043404qab.17
        for <netdev@vger.kernel.org>; Fri, 11 Oct 2013 13:41:59 -0700 (PDT)
In-Reply-To: <1381499540-28794-15-git-send-email-matthew.leach@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Oct 2013, Matthew Leach wrote:

> From: Will Deacon <will.deacon@arm.com>
> 
> SMC_outw invokes an endian-aware I/O accessor, which may change the data
> endianness before writing to the device. This is not suitable for data
> transfers where the memory buffer is simply a string of bytes that does
> not require any byte-swapping.
> 
> This patches fixes the smc91x SMC_PUSH_DATA macro so that it uses the
> string I/O accessor for outputting the leading or trailing halfwords on
> halfword-aligned buffers.

Acked-by: Nicolas Pitre <nico@linaro.org>

> 
> Cc: <netdev@vger.kernel.org>
> Cc: Nicolas Pitre <nico@fluxnic.net>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Will Deacon <will.deacon@arm.com>
> ---
>  drivers/net/ethernet/smsc/smc91x.h |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
> index 5730fe2..98eedb9 100644
> --- a/drivers/net/ethernet/smsc/smc91x.h
> +++ b/drivers/net/ethernet/smsc/smc91x.h
> @@ -1124,8 +1124,7 @@ static const char * chip_ids[ 16 ] =  {
>  			void __iomem *__ioaddr = ioaddr;		\
>  			if (__len >= 2 && (unsigned long)__ptr & 2) {	\
>  				__len -= 2;				\
> -				SMC_outw(*(u16 *)__ptr, ioaddr,		\
> -					DATA_REG(lp));		\
> +				SMC_outsw(ioaddr, DATA_REG(lp), __ptr, 1); \
>  				__ptr += 2;				\
>  			}						\
>  			if (SMC_CAN_USE_DATACS && lp->datacs)		\
> @@ -1133,8 +1132,7 @@ static const char * chip_ids[ 16 ] =  {
>  			SMC_outsl(__ioaddr, DATA_REG(lp), __ptr, __len>>2); \
>  			if (__len & 2) {				\
>  				__ptr += (__len & ~3);			\
> -				SMC_outw(*((u16 *)__ptr), ioaddr,	\
> -					 DATA_REG(lp));		\
> +				SMC_outsw(ioaddr, DATA_REG(lp), __ptr, 1); \
>  			}						\
>  		} else if (SMC_16BIT(lp))				\
>  			SMC_outsw(ioaddr, DATA_REG(lp), p, (l) >> 1);	\
> -- 
> 1.7.9.5
> 
