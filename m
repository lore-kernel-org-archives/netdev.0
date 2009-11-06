From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: should not use __dev_get_by_index() without locks
Date: Fri, 06 Nov 2009 12:04:16 +0100
Message-ID: <4AF402B0.7090202@hartkopp.net>
References: <4AF3F905.4030608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:61458 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755075AbZKFLEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 06:04:09 -0500
In-Reply-To: <4AF3F905.4030608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> David
> 
> A more elegant patch will be possible for 2.6.33, but for 2.6.32,
> I think following patch is needed (Please note I did not test it)
> 
> (More elegant : use RCU lookups ;) , I'll wait for net-next-2.6 
>  upgrade as well)
> 
> Thanks
> 
> [PATCH] can: should not use __dev_get_by_index() without locks
> 
> bcm_proc_getifname() is called with RTNL and dev_base_lock
> not held. It calls __dev_get_by_index() without locks, and
> this is illegal (might crash)
> 
> Close the race by holding dev_base_lock and copying dev->name
> in the protected section.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks for pointing this out.
This is a quite old code section which is not used very often at runtime - and
usually the netdevice is not removed at that time ;-)

Btw. this is no excuse for that missing locking, sorry.

Thanks for the fix!

Compiled and tested successfully.

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>


