From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] kcm: fix a socket double free
Date: Wed, 31 Aug 2016 21:00:59 -0700 (PDT)
Message-ID: <20160831.210059.26103204048434366.davem@davemloft.net>
References: <1472444906-9566-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, tom@herbertland.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53162 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750696AbcIAEBD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 00:01:03 -0400
In-Reply-To: <1472444906-9566-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Sun, 28 Aug 2016 21:28:26 -0700

> Dmitry reported a double free on kcm socket, which could
> be easily reproduced by:
> 
> 	#include <unistd.h>
> 	#include <sys/syscall.h>
> 
> 	int main()
> 	{
> 	  int fd = syscall(SYS_socket, 0x29ul, 0x5ul, 0x0ul, 0, 0, 0);
> 	  syscall(SYS_ioctl, fd, 0x89e2ul, 0x20a98000ul, 0, 0, 0);
> 	  return 0;
> 	}
> 
> This is because on the error path, after we install
> the new socket file, we call sock_release() to clean
> up the socket, which leaves the fd pointing to a freed
> socket. Fix this by calling sys_close() on that fd
> directly.
> 
> Fixes: ab7ac4eb9832 ("kcm: Kernel Connection Multiplexor module")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
