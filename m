From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] inet: add proper locking in __inet{6}_lookup()
Date: Mon, 28 Mar 2016 07:23:55 -0700
Message-ID: <1459175035.6473.92.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458944115.6473.62.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160327.223222.486104825905902179.davem@davemloft.net>
	 <1459171772.6473.86.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1459174213.6473.87.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:32874 "EHLO
	mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306AbcC1OYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 10:24:35 -0400
Received: by mail-vk0-f42.google.com with SMTP id k1so156920654vkb.0
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 07:24:35 -0700 (PDT)
In-Reply-To: <1459174213.6473.87.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-28 at 07:10 -0700, Eric Dumazet wrote:
> On Mon, 2016-03-28 at 06:29 -0700, Eric Dumazet wrote:
> 
> > Sure, but the caller changed quite a lot in all stable versions.
> > 
> > I took the easiest path for stable maintainers, and was planing to
> > implement a better way in net-next.
> 
> I misread your suggestion David, I send a V2 shortly.
> 

Actually, I'll wait for net-next opening.

My brain farted while working on the 'non refcounted TCP listener'
because __inet_lookup_listener() will really need to be called from
enclosed rcu_read_lock(), and for a reason I though net tree had a bug.

The local_bh_disable()/local_bh_enable() removal can certainly wait
net-next.

Sorry for the confusion.
