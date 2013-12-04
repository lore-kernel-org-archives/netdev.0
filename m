From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for
 neigh_timer_handler()
Date: Wed, 04 Dec 2013 07:24:05 -0800
Message-ID: <1386170645.30495.108.camel@edumazet-glaptop2.roam.corp.google.com>
References: <529DE13D.2070509@huawei.com>	<529E9579.7090201@cn.fujitsu.com>
			<529EA9CF.2090008@huawei.com>
		 <20131203.232122.852236751455974887.davem@davemloft.net>
		 <529EC95A.5080908@huawei.com>
	 <1386138457.30495.86.camel@edumazet-glaptop2.roam.corp.google.com>
	 <529EF30A.4050609@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, gaofeng@cn.fujitsu.com,
	yoshfuji@linux-ipv6.org, joe@perches.com, vfalico@redhat.com,
	netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:48346 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932319Ab3LDPYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 10:24:07 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so22544779pdj.17
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 07:24:06 -0800 (PST)
In-Reply-To: <529EF30A.4050609@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-04 at 17:16 +0800, Ding Tianhong wrote:
> >> 						base->running_timer = neigh->timer;
> >> 						neigh_timer_handler() => at this time, refcnt is 2;
> >>
> >> user->	neigh_changeaddr()
> >> 	neigh_flush_dev();
> >> 	neigh_del_imer, refcnt dec to 1;
> > 
> > Nope : del_timer() would return 0 here, so we do not decrement refcnt.
> > 
> 
> The first call for del_timer() will return 1, because the timer->entry.next is not NULL,
> then in the neigh_destroy, the del_timer() again will return 0 because timer->entry.next is NULL. 

Again no. You are very mistaken.

del_timer() return code is not a hint. Its a precise meaning.

It cannot return 1 if the timer function is running or is about to run.

If you believe there is  bug in del_timer(), fix it ;)
