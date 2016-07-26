From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [v3] UCC_GETH/UCC_FAST: Use IS_ERR_VALUE_U32 API to avoid IS_ERR_VALUE abuses.
Date: Tue, 26 Jul 2016 13:39:15 +0200
Message-ID: <4175803.I7CDUloLxQ@wuerfel>
References: <1469297151-9763-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>, zajec5@gmail.com,
	leoli@freescale.com, qiang.zhao@freescale.com,
	viresh.kumar@linaro.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, scottwood@freescale.com,
	akpm@linux-foundation.org, linux@roeck-us.net
To: linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:57677 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbcGZLkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 07:40:14 -0400
In-Reply-To: <1469297151-9763-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday, July 23, 2016 11:35:51 PM CEST Arvind Yadav wrote:
> diff --git a/include/linux/err.h b/include/linux/err.h
> index 1e35588..a42f942 100644
> --- a/include/linux/err.h
> +++ b/include/linux/err.h
> @@ -19,6 +19,7 @@
>  #ifndef __ASSEMBLY__
>  
>  #define IS_ERR_VALUE(x) unlikely((unsigned long)(void *)(x) >= (unsigned long)-MAX_ERRNO)
> +#define IS_ERR_VALUE_U32(x) unlikely((unsigned int)(x) >= (unsigned int)-MAX_ERRNO)
>  
>  static inline void * __must_check ERR_PTR(long error)
>  {

This doesn't really look like something we want to have as a generic
interface. The IS_ERR_VALUE() API is rather awkward already, and your
use seems specific to the cpu_muram_alloc() function.

How about something like

int cpm_muram_error(unsigned long addr)
{
	if (addr >= (unsigned long)-MAX_ERRNO)
		return addr;
	else
		return 0;
}

and then use that to check the value returned by the allocation
that is still an 'unsigned long', before assigning it to a 'u32'.

	Arnd
