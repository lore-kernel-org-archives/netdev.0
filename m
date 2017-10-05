From: Brian Norris <briannorris@chromium.org>
Subject: Re: [PATCH] mwifiex: Use put_unaligned_le32
Date: Thu, 5 Oct 2017 11:02:50 -0700
Message-ID: <20171005180248.GA94139@google.com>
References: <1507141686-5178-1-git-send-email-himanshujha199640@gmail.com>
 <874lre5a86.fsf@codeaurora.org>
 <20171005083433.GA11485@himanshu-Vostro-3559>
 <87zi963s1p.fsf@codeaurora.org>
 <20171005152233.GA6250@himanshu-Vostro-3559>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kvalo@codeaurora.org>, amitkarwar@gmail.com,
        nishants@marvell.com, gbhat@marvell.com, huxm@marvell.com,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Himanshu Jha <himanshujha199640@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:54831 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751415AbdJESCx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 14:02:53 -0400
Received: by mail-pf0-f177.google.com with SMTP id m28so3364742pfi.11
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 11:02:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171005152233.GA6250@himanshu-Vostro-3559>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 05, 2017 at 08:52:33PM +0530, Himanshu Jha wrote:
> There are various instances where a function used in file say for eg
> int func_align (void* a)
> is used and it is defined in align.h
> But many files don't *directly* include align.h and rather include
> any other header which includes align.h

I believe the general rule is that you should included headers for all
symbols you use, and not rely on implicit includes.

The modification to the general rule is that not all headers are
intended to be included directly, and in such cases there's likely a
parent header that is the more appropriate target.

In this case, the key is CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS. It
seems that asm-generic/unaligned.h is set up to include different
headers, based on the expected architecture behavior.

I wonder if include/linux/unaligned/access_ok.h should have a safety
check (e.g., raise an #error if
!CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS?).

> Is compiling the file the only way to check if apppropriate header is
> included or is there some other way to check for it.

I believe it's mostly manual. Implicit includes have been a problem for
anyone who refactors header files.

Brian
