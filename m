From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Does rtnl_lock inhibit incoming traffic?
Date: Wed, 29 May 2013 13:21:20 -0700
Message-ID: <1369858880.5109.82.camel@edumazet-glaptop>
References: <51A6522D.2000008@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:58944 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966903Ab3E2UVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 16:21:22 -0400
Received: by mail-pb0-f50.google.com with SMTP id wy17so9733174pbc.37
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 13:21:22 -0700 (PDT)
In-Reply-To: <51A6522D.2000008@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-29 at 21:08 +0200, Oliver Hartkopp wrote:
> Hello,
> 
> AFAIK the rtnl_lock is used (at least) to protect the configuration of
> netdevices and routing tables.
> 
> Is the reception of incoming traffic inhibited while the rtnl_lock is set, or
> would i need to protect the data structures to be modified with an additional
> spinlock_bh() / write_lock_bh()?
> 
> Like this one here:
> 
> http://lxr.linux.no/#linux+v3.9.4/net/ipv6/ip6mr.c#L1573


Reception of incoming traffic is not inhibited by rtnl.

And spinlock_bh()/write_lock_bh() only disable current cpu from
receiving frames, but other cpus can still handle incoming traffic.
