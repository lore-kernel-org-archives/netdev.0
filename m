From: Himanshu Jha <himanshujha199640@gmail.com>
Subject: Re: [PATCH] mwifiex: Use put_unaligned_le32
Date: Thu, 5 Oct 2017 14:04:33 +0530
Message-ID: <20171005083433.GA11485@himanshu-Vostro-3559>
References: <1507141686-5178-1-git-send-email-himanshujha199640@gmail.com>
 <874lre5a86.fsf@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amitkarwar@gmail.com, nishants@marvell.com, gbhat@marvell.com,
        huxm@marvell.com, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <874lre5a86.fsf@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2017 at 10:23:37AM +0300, Kalle Valo wrote:
> Himanshu Jha <himanshujha199640@gmail.com> writes:
> 
> > Use put_unaligned_le32 rather than using byte ordering function and
> > memcpy which makes code clear.
> > Also, add the header file where it is declared.
> >
> > Done using Coccinelle and semantic patch used is :
> >
> > @ rule1 @
> > identifier tmp; expression ptr,x; type T;
> > @@
> >
> > - tmp = cpu_to_le32(x);
> >
> >   <+... when != tmp
> > - memcpy(ptr, (T)&tmp, ...);
> > + put_unaligned_le32(x,ptr);
> >   ...+>
> >
> > @ depends on rule1 @
> > type j; identifier tmp;
> > @@
> >
> > - j tmp;
> >   ...when != tmp
> >
> > Signed-off-by: Himanshu Jha <himanshujha199640@gmail.com>
> > ---
> >  drivers/net/wireless/marvell/mwifiex/cmdevt.c | 10 ++++------
> >  1 file changed, 4 insertions(+), 6 deletions(-)
> >
> > diff --git a/drivers/net/wireless/marvell/mwifiex/cmdevt.c b/drivers/net/wireless/marvell/mwifiex/cmdevt.c
> > index 0edc5d6..e28e119 100644
> > --- a/drivers/net/wireless/marvell/mwifiex/cmdevt.c
> > +++ b/drivers/net/wireless/marvell/mwifiex/cmdevt.c
> > @@ -17,6 +17,7 @@
> >   * this warranty disclaimer.
> >   */
> >  
> > +#include <linux/unaligned/access_ok.h>
> 
> I don't think this is correct. Should it be asm/unaligned.h?

Would mind explainig me as to why it is incorrect! Also, it defined in
both the header files but, why is asm/unaligned.h preferred ?

Thanks

> -- 
> Kalle Valo
