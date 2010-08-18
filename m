From: Dmitry Kozlov <xeb@mail.ru>
Subject: =?koi8-r?Q?Re=3A_[PATCH_v4]_PPTP=3A_PPP_over_IPv4_(Point-to-Point_Tunneling_Protocol)?=
Date: Wed, 18 Aug 2010 17:16:09 +0400
Message-ID: <E1OliUz-0006py-00.xeb-mail-ru@f121.mail.ru>
References: <1282136626.2194.68.camel@edumazet-laptop>
Reply-To: Dmitry Kozlov <xeb@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from f121.mail.ru ([217.69.128.80]:58781 "EHLO f121.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751137Ab0HRNQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Aug 2010 09:16:12 -0400
In-Reply-To: <1282136626.2194.68.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hmm. You left a synchronize_rcu() call in add_chan() but this is not
> necessary. Please remove it or explain why you think it is needed.
> 
> synchronize_rcu(); in del_chan() is now fine, thanks.
> 
> 
> You use a mutex for gre_proto_lock, but you dont need a mutex, please
> use a spinlock like I suggested. I would have said 'use a mutex' if if
> was needed, you can trust me.

ok

> A mutex is needed if you can sleep while holding the lock, this is not
> the case here. A spinlock is faster and reduces to no-op on !SMP

then i have to replace mutex on spinlock in pptp module too ?

> Also, please remove the synchronize_rcu() call from gre_add_protocol() :
> It is not needed at all, like in add_chan().
> 
> (You dont have to wait for a RCU grace period when adding something,
> only when removing from a data structure)

ok, seems like i don't fully understand rcu mechanism...

Thanks for reply.

