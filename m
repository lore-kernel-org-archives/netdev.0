From: Himanshu Jha <himanshujha199640@gmail.com>
Subject: Re: [PATCH] mwifiex: Use put_unaligned_le32
Date: Thu, 5 Oct 2017 20:52:33 +0530
Message-ID: <20171005152233.GA6250@himanshu-Vostro-3559>
References: <1507141686-5178-1-git-send-email-himanshujha199640@gmail.com>
 <874lre5a86.fsf@codeaurora.org>
 <20171005083433.GA11485@himanshu-Vostro-3559>
 <87zi963s1p.fsf@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amitkarwar@gmail.com, nishants@marvell.com, gbhat@marvell.com,
        huxm@marvell.com, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87zi963s1p.fsf@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2017 at 11:41:38AM +0300, Kalle Valo wrote:
> Himanshu Jha <himanshujha199640@gmail.com> writes:
> 
> >> > --- a/drivers/net/wireless/marvell/mwifiex/cmdevt.c
> >> > +++ b/drivers/net/wireless/marvell/mwifiex/cmdevt.c
> >> > @@ -17,6 +17,7 @@
> >> >   * this warranty disclaimer.
> >> >   */
> >> >  
> >> > +#include <linux/unaligned/access_ok.h>
> >> 
> >> I don't think this is correct. Should it be asm/unaligned.h?
> >
> > Would mind explainig me as to why it is incorrect! Also, it defined in
> > both the header files but, why is asm/unaligned.h preferred ?
> 
> asm/unaligned.h seems to be the toplevel header file which includes
> header files based on arch configuration. Also grepping the sources
> support that, nobody from drivers/ include access_ok.h directly.
>
Yes, you are correct!

I will send v2 patch with asm/unaligned.h

> But I can't say that I fully understand how the header files work so
> please do correct me if I have mistaken.
>
It is confusing to me as well.
There are various instances where a function used in file say for eg
int func_align (void* a)
is used and it is defined in align.h
But many files don't *directly* include align.h and rather include
any other header which includes align.h

Is compiling the file the only way to check if apppropriate header is
included or is there some other way to check for it.

Thanks
