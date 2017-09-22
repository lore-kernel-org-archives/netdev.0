From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] wireless: iwlegacy: make const array static to shink
 object code size Content-Type: text/plain; charset="utf-8" Content-Transfer-Encoding:
 8bit
Date: Fri, 22 Sep 2017 12:06:20 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1709221206050.3170@hadrien>
References: <20170921225630.21916-1-colin.king@canonical.com> <alpine.DEB.2.20.1709220921350.2024@hadrien> <1506074588.12311.37.camel@perches.com> <f6cb5b73-4ed5-92d9-3909-32b8e3aafc45@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>,
        Stanislaw Gruszka <sgruszka@redhat.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f6cb5b73-4ed5-92d9-3909-32b8e3aafc45@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 22 Sep 2017, Colin Ian King wrote:

> On 22/09/17 11:03, Joe Perches wrote:
> > On Fri, 2017-09-22 at 09:23 +0200, Julia Lawall wrote:
> >>
> >> On Thu, 21 Sep 2017, Colin King wrote:
> >>
> >>> From: Colin Ian King <colin.king@canonical.com>
> >>>
> >>> Don't populate const array ac_to_fifo on the stack in an inlined
> >>> function, instead make it static.  Makes the object code smaller
> >>> by over 800 bytes:
> >>>
> >>>    text	   data	    bss	    dec	    hex	filename
> >>>  159029	  33154	   1216	 193399	  2f377	4965-mac.o
> >>>
> >>>    text	   data	    bss	    dec	    hex	filename
> >>>  158122	  33250	   1216	 192588	  2f04c	4965-mac.o
> >>>
> >>> (gcc version 7.2.0 x86_64)
> >>
> >> Gcc 7 must be much more aggressive about inlining than gcc 4.  Here is the
> >> change that I got on this file:
> >>
> >>      text          data     bss     dec     hex filename
> >> -   76346          1494     152   77992   130a8 drivers/net/wireless/intel/iwlegacy/4965-mac.o
> >> +   76298          1494     152   77944   13078 drivers/net/wireless/intel/iwlegacy/4965-mac.o
> >> decrease of 48
> >
> > More likely different CONFIG options.
> >
> > e.g. allyesconfig vs defconfig with wireless
> >
> yup, I used allyesconfig

Mine is also allyesconfig.

julia

>
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
