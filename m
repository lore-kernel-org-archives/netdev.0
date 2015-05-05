From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 10/10] net: dsa: Add lockdep class to tx queues
 to avoid lockdep splat
Date: Tue, 05 May 2015 16:22:33 -0700
Message-ID: <554950B9.4020807@gmail.com>
References: <1430867396-2268-1-git-send-email-andrew@lunn.ch> <1430867396-2268-11-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, davem@davemloft.net,
	linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:34683 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125AbbEEXWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:22:49 -0400
Received: by pdbqa5 with SMTP id qa5so211641295pdb.1
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 16:22:48 -0700 (PDT)
In-Reply-To: <1430867396-2268-11-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/05/15 16:09, Andrew Lunn wrote:
> DSA stacks an Ethernet device on top of an Ethernet device. This can
> cause false positive lockdep splats for the transmit queue:
> 
> =============================================
> [ INFO: possible recursive locking detected ]
> 4.0.0-rc7-01838-g70621a215fc7 #386 Not tainted
> ---------------------------------------------
> kworker/0:0/4 is trying to acquire lock:
>  (_xmit_ETHER#2){+.-...}, at: [<c040e95c>] sch_direct_xmit+0xa8/0x1fc
> 
> but task is already holding lock:
>  (_xmit_ETHER#2){+.-...}, at: [<c03f4208>] __dev_queue_xmit+0x4d4/0x56c
> 
> other info that might help us debug this:
>  Possible unsafe locking scenario:
> 
>        CPU0
>        ----
>   lock(_xmit_ETHER#2);
>   lock(_xmit_ETHER#2);
> 
> To avoid this, walk the tq queues of the dsa slaves and set a lockdep
> class.

Had meant to fix that a while ago when this was bugging me, thanks for
doing this!

> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
