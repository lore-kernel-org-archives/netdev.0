Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Wed, 20 Sep 2017 15:36:39 -0700 (PDT)
Message-Id: <20170920.153639.1370296452987488590.davem@davemloft.net>
To: mengxu.gatech@gmail.com
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        meng.xu@gatech.edu, sanidhya@gatech.edu, taesoo@gatech.edu
Subject: Re: [PATCH] net: compat: assert the size of cmsg copied in is as
 expected
From: David Miller <davem@davemloft.net>
In-Reply-To: <1505841553-39084-1-git-send-email-mengxu.gatech@gmail.com>
References: <1505841553-39084-1-git-send-email-mengxu.gatech@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Meng Xu <mengxu.gatech@gmail.com>
Date: Tue, 19 Sep 2017 13:19:13 -0400

> The actual length of cmsg fetched in during the second loop
> (i.e., kcmsg - kcmsg_base) could be different from what we
> get from the first loop (i.e., kcmlen).
> 
> The main reason is that the two get_user() calls in the two
> loops (i.e., get_user(ucmlen, &ucmsg->cmsg_len) and
> __get_user(ucmlen, &ucmsg->cmsg_len)) could cause ucmlen
> to have different values even they fetch from the same userspace
> address, as user can race to change the memory content in
> &ucmsg->cmsg_len across fetches.
> 
> Although in the second loop, the sanity check
> if ((char *)kcmsg_base + kcmlen - (char *)kcmsg < CMSG_ALIGN(tmp))
> is inplace, it only ensures that the cmsg fetched in during the
> second loop does not exceed the length of kcmlen, but not
> necessarily equal to kcmlen. But indicated by the assignment
> kmsg->msg_controllen = kcmlen, we should enforce that.
> 
> This patch adds this additional sanity check and ensures that
> what is recorded in kmsg->msg_controllen is the actual cmsg length.
> 
> Signed-off-by: Meng Xu <mengxu.gatech@gmail.com>

Applied, thanks.
