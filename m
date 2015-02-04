From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: One function call less in em_meta_change()
 after error detection
Date: Tue, 03 Feb 2015 16:10:54 -0800 (PST)
Message-ID: <20150203.161054.379086029122558267.davem@davemloft.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<54CD042E.6030606@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <54CD042E.6030606@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 31 Jan 2015 17:34:54 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 31 Jan 2015 17:18:48 +0100
> 
> The meta_delete() function could be called in four cases by the
> em_meta_change() function during error handling even if the passed
> variable "meta" contained still a null pointer.
> 
> * This implementation detail could be improved by adjustments for jump labels.
> 
> * Let us return immediately after the first failed function call according to
>   the current Linux coding style convention.
> 
> * Let us delete also unnecessary checks for the variables "err" and
>   "meta" there.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

I kind of like the way the code is now, branching to the end of the function
even when cleanups are not necessary.

Inter-function return statements make code harder to audit, for locking
errors, resource leaks, etc.
