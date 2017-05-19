From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] fix BUG: scheduling while atomic in netlink broadcast
Date: Fri, 19 May 2017 10:46:51 -0700
Message-ID: <CAM_iQpXraspjEvh9Wy5jOscFz7zKS4Z3XsigxCJFJ5_RuCOnyw@mail.gmail.com>
References: <CAN-7y0oY=LyeLTxhC5L+Vjy-NivmRJSBpqPP9+NYT7a=NFV0_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Akshay Narayan <akshayn@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35397 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753974AbdESRrM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 13:47:12 -0400
Received: by mail-wm0-f48.google.com with SMTP id b84so242325331wmh.0
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:47:12 -0700 (PDT)
In-Reply-To: <CAN-7y0oY=LyeLTxhC5L+Vjy-NivmRJSBpqPP9+NYT7a=NFV0_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 10:22 AM, Akshay Narayan <akshayn@mit.edu> wrote:
> netlink_broadcast_filtered() calls yield() when a slow listener causes
> the buffer to fill. yield() is the wrong choice here, as pointed out by
> Commit 8e3fabfde4 (sched: Update yield() docs); in some cases, its use causes
> "BUG: scheduling while atomic" and, when fewer cores are available,
> kernel hangs:


I don't want to defend the use of yield() but it looks like there is other
problem.

>
> (note: "ccp" is a kernel module which multicasts netlink messages upon
> certain TCP events)

Does this module call netlink_broadcast() with __GFP_DIRECT_RECLAIM
in IRQ context? If so you should adjust the gfp flags.
