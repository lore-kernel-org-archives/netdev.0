From: David Miller <davem@davemloft.net>
Subject: Re: net-next: warnings from sysctl_net_exit
Date: Sat, 26 Feb 2011 22:23:33 -0800 (PST)
Message-ID: <20110226.222333.59680338.davem@davemloft.net>
References: <20110226165601.48858003@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49200
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750989Ab1B0GW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 01:22:57 -0500
In-Reply-To: <20110226165601.48858003@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sat, 26 Feb 2011 16:56:01 -0800

> Seeing lots of these messages in dmesg. Something is broken
> recently in net-next.

Did you by change pull plain net-2.6 into that tree?  Because one
commit which is in net-2.6 but not in net-next-2.6 catches my eye:

commit c486da34390846b430896a407b47f0cea3a4189c
Author: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Date:   Thu Feb 24 19:48:03 2011 +0000

    sysctl: ipv6: use correct net in ipv6_sysctl_rtcache_flush
    
    Before this patch issuing these commands:
    
      fd = open("/proc/sys/net/ipv6/route/flush")
      unshare(CLONE_NEWNET)
      write(fd, "stuff")
    
    would flush the newly created net, not the original one.
    
    The equivalent ipv4 code is correct (stores the net inside ->extra1).
    Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

