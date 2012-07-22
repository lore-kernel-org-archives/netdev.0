From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix references to out-of-scope variables in
 put_cmsg_compat()
Date: Sun, 22 Jul 2012 14:54:07 -0700 (PDT)
Message-ID: <20120722.145407.2163219263880320745.davem@davemloft.net>
References: <alpine.LNX.2.00.1207222335200.31033@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1207222335200.31033@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Sun, 22 Jul 2012 23:37:20 +0200 (CEST)

> In net/compat.c::put_cmsg_compat() we may assign 'data' the address of
> either the 'ctv' or 'cts' local variables inside the 'if
> (!COMPAT_USE_64BIT_TIME)' branch.
> 
> Those variables go out of scope at the end of the 'if' statement, so
> when we use 'data' further down in 'copy_to_user(CMSG_COMPAT_DATA(cm),
> data, cmlen - sizeof(struct compat_cmsghdr))' there's no telling what
> it may be refering to - not good.
> 
> Fix the problem by simply giving 'ctv' and 'cts' function scope.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied and queued up for -stable, thanks.
