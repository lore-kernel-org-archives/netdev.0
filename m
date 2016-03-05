From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Sat, 5 Mar 2016 18:57:14 +0300
Message-ID: <20160305155714.GM4184@uranus.lan>
References: <20160304213920.GJ4184@uranus.lan>
 <20160304.175032.1728003538386465719.davem@davemloft.net>
 <1457136510.2761.8.camel@edumazet-ThinkPad-T530>
 <20160304.231109.1838919633640757059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:36550 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919AbcCEP5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2016 10:57:23 -0500
Received: by mail-lb0-f180.google.com with SMTP id x1so90866173lbj.3
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2016 07:57:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160304.231109.1838919633640757059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 04, 2016 at 11:11:09PM -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 04 Mar 2016 16:08:30 -0800
> 
> > __inet_del_ifa() should probably take into account in_dev->dead (no
> > promotion, no list scan...)
> 
> Indeed, that is the real problem:

Well, tried it out. Indeed it partially released the contention
but with patch applied I stuck with

Samples: 20K of event 'cpu-clock', Event count (approx.): 4647374938
Overhead  Shared Object        Symbol
  19.27%  [kernel]             [k] __local_bh_enable_ip
  15.97%  [kernel]             [k] lock_acquire
  15.12%  [kernel]             [k] fib_del_ifaddr
  11.66%  [kernel]             [k] lock_release
   7.57%  [kernel]             [k] lock_is_held
   5.35%  [kernel]             [k] lock_acquired
   3.26%  [kernel]             [k] _raw_spin_unlock_irqrestore
   3.04%  [kernel]             [k] __local_bh_disable_ip
   2.10%  [kernel]             [k] _raw_spin_unlock_irq
   1.54%  [kernel]             [k] native_save_fl
   1.37%  [kernel]             [k] ___might_sleep
   0.90%  [kernel]             [k] do_raw_spin_trylock
   0.83%  [kernel]             [k] nf_ct_iterate_cleanup
   0.77%  [kernel]             [k] debug_lockdep_rcu_enabled
   0.62%  [kernel]             [k] tick_nohz_idle_enter
   0.61%  [kernel]             [k] _raw_spin_lock
   0.58%  [kernel]             [k] __slab_alloc.isra.43.constprop.47
   0.42%  [kernel]             [k] get_parent_ip
   0.40%  [kernel]             [k] preempt_count_sub
   0.36%  [kernel]             [k] native_save_fl
   0.34%  [kernel]             [k] _raw_spin_unlock
   0.31%  [kernel]             [k] do_raw_spin_unlock

and until everything get cleaned up I couldn't connect
to the node via ssh. I continue playing with patch maybe
I find some other optimization paths. Thanks!
