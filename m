From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] netns: correct gfp flags for alloc_netid()
Date: Thu, 26 Feb 2015 17:49:51 -0800
Message-ID: <1425001791.5565.180.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424998490-9565-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:33722 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbbB0Btx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 20:49:53 -0500
Received: by iecar1 with SMTP id ar1so24278429iec.0
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 17:49:53 -0800 (PST)
In-Reply-To: <1424998490-9565-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-26 at 16:54 -0800, Cong Wang wrote:
> This fixes the following kernel warning:
> 
>  ===============================
>  [ INFO: suspicious RCU usage. ]
>  3.19.0+ #805 Tainted: G        W      
>  -------------------------------
>  include/linux/rcupdate.h:538 Illegal context switch in RCU read-side critical section!
>  
>  other info that might help us debug this:
>  

I do not think this is the right way to fix this.

Bug is that rtnl_dump_ifinfo() should not use rcu_read_lock(), as RTNL
is held : GFP_KERNEL allocations in control path should be the golden
rule.

I guess I should have reverted e67f88dd12f6 completely
instead of the partial revert (2907c35ff647080)
