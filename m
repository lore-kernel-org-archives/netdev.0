From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Fri, 04 Mar 2016 16:08:30 -0800
Message-ID: <1457136510.2761.8.camel@edumazet-ThinkPad-T530>
References: <20160304213920.GJ4184@uranus.lan>
	 <20160304.175032.1728003538386465719.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gorcunov@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35955 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760388AbcCEAId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 19:08:33 -0500
Received: by mail-pa0-f43.google.com with SMTP id fi3so40875648pac.3
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 16:08:33 -0800 (PST)
In-Reply-To: <20160304.175032.1728003538386465719.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ven., 2016-03-04 at 17:50 -0500, David Miller wrote:
> From: Cyrill Gorcunov <gorcunov@gmail.com>
> Date: Sat, 5 Mar 2016 00:39:20 +0300
> 
> > Currenlty all the kernels (including vanilla) free ifa
> > list under rtln_lock() taken which takes a huge time
> > to release all entries when we stop the container.
> > Moreover it's allowed to create unlimited number
> > of addresses from inside of net-namespace if
> > CAP-NET_ADMIN granted (which is common for containers).
> > 
> > Lets introduce per-net limit (4096 by default)
> > of addresses, which can be tuned up via sysfs
> > entry /proc/sys/net/ipv4/ifa_limit.
> > 
> > Reported-by: Solar Designer <solar@openwall.com>
> > Signed-off-by: Cyrill Gorcunov <gorcunov@virtuozzo.com>
> 
> Arbitrary limits are... arbitrary.
> 
> If the freeing loop is the issue, splice the list at teardown and
> process that list asynchronously via a workqueue or similar.
> 
> Thanks.

Also I wonder if the problem is not a quadratic behavior.

__inet_del_ifa() should probably take into account in_dev->dead  (no
promotion, no list scan...)
