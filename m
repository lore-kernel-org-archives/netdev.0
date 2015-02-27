From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] netns: avoid allocating idr when dumping info
Date: Fri, 27 Feb 2015 00:01:09 -0800
Message-ID: <1425024069.5130.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425018776-14725-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:35209 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430AbbB0IBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 03:01:11 -0500
Received: by iecrl12 with SMTP id rl12so27407487iec.2
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 00:01:11 -0800 (PST)
In-Reply-To: <1425018776-14725-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-26 at 22:32 -0800, Cong Wang wrote:
> We can allocate the peer netns id when creating the link
> instead of when dumping the link.
> 
> This fixes the following kernel warning:
> 
>  ===============================
>  [ INFO: suspicious RCU usage. ]
>  3.19.0+ #805 Tainted: G        W
>  -------------------------------
>  include/linux/rcupdate.h:538 Illegal context switch in RCU read-side critical section!
> 
>  other info that might help us debug this:

This looks very complicated, why even bother ?

I gave an obvious patch fixing root cause, I have no idea why you prefer
over engineering this.

If you believe allocating peer netns id is required at link creation
time, you should explain why.

BTW, (void)peernet2id(dev_net(dev), src_net) can fail, and your fix is
not complete anyway.
