From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH RFC] reciprocal_divide: correction/update of the algorithm
Date: Tue, 14 Jan 2014 10:02:19 -0800
Message-ID: <52D57BAB.5070709@infradead.org>
References: <20140113214249.GK6586@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, dborkman@redhat.com,
	eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	darkjames-ws@darkjames.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:40712 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631AbaANSCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 13:02:22 -0500
In-Reply-To: <20140113214249.GK6586@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2014 01:42 PM, Hannes Frederic Sowa wrote:
> 
> I propose an correction/update of the algorithm
> based on the paper "T. Granlund and P. L. Montgomery:
> Division by Invariant Integers Using Multiplication"
> <http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.1.2556>
> 
> The assembler implementation from Agner Fog, found here
> <http://www.agner.org/optimize/asmlib.zip>, helped a lot while
> implementing.
> 
> I would like to have feedback if people see problems with this patch or
> have concerns about performance. I did some testing on x86-64 and found
> no problems so far but did no performance evaluation, yet.
> 
> The current code does break the call-sides of reciprocal_divide. The necessary
> changes will be part of the full series, then.
> 
> Thanks!
> ---
>  include/linux/reciprocal_div.h | 12 +++++++++---
>  lib/reciprocal_div.c           | 22 ++++++++++++++++++----
>  2 files changed, 27 insertions(+), 7 deletions(-)

Just trivia (coding style and spelling):

> diff --git a/lib/reciprocal_div.c b/lib/reciprocal_div.c
> index 75510e9..b741b30 100644
> --- a/lib/reciprocal_div.c
> +++ b/lib/reciprocal_div.c
> @@ -1,11 +1,25 @@
> +#include <linux/kernel.h>
>  #include <asm/div64.h>
>  #include <linux/reciprocal_div.h>
>  #include <linux/export.h>
>  
> -u32 reciprocal_value(u32 k)
> +/* For a description of the algorithmus please look at

                               algorithms

> + * linux/reciprocal_div.h
> + */

and kernel coding style for multi-line comments is like so:

/*
 * For a description of the algorithms, please look at
 * linux/reciprocal_div.h
 */

> +
> +struct reciprocal_value reciprocal_value(u32 d)
>  {



-- 
~Randy
