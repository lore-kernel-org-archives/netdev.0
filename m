From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Thu, 27 Nov 2008 13:42:58 -0800
Message-ID: <492F1462.4020803@zytor.com>
References: <492DD792.6080302@linux.intel.com>	<20081127115236.GE29013@elte.hu>	<492EE087.80708@linux.intel.com>	<20081127201836.GA16869@elte.hu> <20081127122800.45fc0b1a@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yinghai@kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	jesse Barnes <jbarnes@virtuousgeek.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:46624 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008AbYK0Vnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 16:43:47 -0500
In-Reply-To: <20081127122800.45fc0b1a@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arjan van de Ven wrote:
> 
> diff --git a/arch/x86/kernel/cpu/mtrr/main.c b/arch/x86/kernel/cpu/mtrr/main.c
> index 1159e26..0044e61 100644
> --- a/arch/x86/kernel/cpu/mtrr/main.c
> +++ b/arch/x86/kernel/cpu/mtrr/main.c
> @@ -1567,6 +1567,8 @@ int __init mtrr_trim_uncached_memory(unsigned long end_pfn)
>  	 * Make sure we only trim uncachable memory on machines that
>  	 * support the Intel MTRR architecture:
>  	 */
> +	if (!cpu_has_mtrr)
> +		return 0;
>  	if (!is_cpu(INTEL) || disable_mtrr_trim)
>  		return 0;
>  	rdmsr(MTRRdefType_MSR, def, dummy);

Okay... is_cpu() here is defined as:

#define is_cpu(vnd)      (mtrr_if && mtrr_if->vendor == X86_VENDOR_##vnd)

... so an MTRR interface has been identified.  Therefore testing 
cpu_has_mtrr is redundant.

As far as use_intel() versus is_cpu(INTEL), it looks to me as though the 
two are identical in the current code -- mtrr_if->vendor is never set in 
the generic code, and so defaults to 0 - meaning X86_VENDOR_INTEL.

All in all, it looks like the vendor ID stuff is a bad case of "works by 
accident" in the MTRR code, however, *given the current code* I conclude 
that is_cpu(INTEL) == use_intel() and that neither can be true without 
MTRRs enabled.

	-hpa
