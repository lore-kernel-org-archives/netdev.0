From: Himanshu Jha <himanshujha199640@gmail.com>
Subject: Re: [PATCH] mwifiex: Use put_unaligned_le32
Date: Fri, 6 Oct 2017 00:37:30 +0530
Message-ID: <20171005190730.GA8043@himanshu-Vostro-3559>
References: <1507141686-5178-1-git-send-email-himanshujha199640@gmail.com>
 <874lre5a86.fsf@codeaurora.org>
 <20171005083433.GA11485@himanshu-Vostro-3559>
 <87zi963s1p.fsf@codeaurora.org>
 <20171005152233.GA6250@himanshu-Vostro-3559>
 <20171005180248.GA94139@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kvalo@codeaurora.org>, amitkarwar@gmail.com,
        nishants@marvell.com, gbhat@marvell.com, huxm@marvell.com,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Brian Norris <briannorris@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171005180248.GA94139@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2017 at 11:02:50AM -0700, Brian Norris wrote:
> On Thu, Oct 05, 2017 at 08:52:33PM +0530, Himanshu Jha wrote:
> > There are various instances where a function used in file say for eg
> > int func_align (void* a)
> > is used and it is defined in align.h
> > But many files don't *directly* include align.h and rather include
> > any other header which includes align.h
> 
> I believe the general rule is that you should included headers for all
> symbols you use, and not rely on implicit includes.
> 
> The modification to the general rule is that not all headers are
> intended to be included directly, and in such cases there's likely a
> parent header that is the more appropriate target.
> 
> In this case, the key is CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS. It
> seems that asm-generic/unaligned.h is set up to include different
> headers, based on the expected architecture behavior.
>
Yes, asm-generic/unaligned.h looks more appopriate and is most generic
implementation of unaligned accesses and  arc specific.

Let's see what Kalle Valo recommends! And then I will send v2 of the
patch.

Thanks for the information!

Himanshu Jha

> I wonder if include/linux/unaligned/access_ok.h should have a safety
> check (e.g., raise an #error if
> !CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS?).
> 
> > Is compiling the file the only way to check if apppropriate header is
> > included or is there some other way to check for it.
> 
> I believe it's mostly manual. Implicit includes have been a problem for
> anyone who refactors header files.
> 
> Brian
