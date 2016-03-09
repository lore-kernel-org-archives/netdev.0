From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Wed, 9 Mar 2016 08:58:52 -0800
Message-ID: <20160309165850.GA49579@ast-mbp.thefacebook.com>
References: <1457136510.2761.8.camel@edumazet-ThinkPad-T530>
 <20160304.231109.1838919633640757059.davem@davemloft.net>
 <20160306100932.GP4184@uranus.lan>
 <1457281392.2663.5.camel@edumazet-ThinkPad-T530>
 <20160306170641.GA8820@uranus.lan>
 <20160309163919.GJ2207@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	solar@openwall.com, vvs@virtuozzo.com, avagin@virtuozzo.com,
	xemul@virtuozzo.com, vdavydov@virtuozzo.com, khorenko@virtuozzo.com
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34812 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933301AbcCIQ64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 11:58:56 -0500
Received: by mail-pf0-f178.google.com with SMTP id 129so45251574pfw.1
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 08:58:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160309163919.GJ2207@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 09, 2016 at 07:39:19PM +0300, Cyrill Gorcunov wrote:
> On Sun, Mar 06, 2016 at 08:06:41PM +0300, Cyrill Gorcunov wrote:
> > > 
> > > Well, this looks like LOCKDEP kernel. Are you really running LOCKDEP on
> > > production kernels ?
> > 
> 
> Hi Eric, David. Sorry for the delay. Finally I've measured the
> latency on the hw. It's i7-2600 cpu with 16G of memory. Here
> are the collected data.
> 
> ---
> Unpatched vanilla
> =================
> 
> commit 7f02bf6b5f5de90b7a331759b5364e41c0f39bf9
> Author: Linus Torvalds <torvalds@linux-foundation.org>
> Date:   Tue Mar 8 09:41:20 2016 -0800
> 
>  Creating new addresses
>  ----------------------
>   19.26%  [kernel]                      [k] check_lifetime
>   13.88%  [kernel]                      [k] __inet_insert_ifa
>   13.01%  [kernel]                      [k] inet_rtm_newaddr
> 
>  Release
>  -------
>   20.96%  [kernel]                    [k] _raw_spin_lock
>   17.79%  [kernel]                    [k] preempt_count_add

above line is an indication that you have:
#if defined(CONFIG_DEBUG_PREEMPT) || defined(CONFIG_PREEMPT_TRACER)
turning it off will speed up things significantly.

>   14.79%  [kernel]                    [k] __local_bh_enable_ip
>   13.08%  [kernel]                    [k] preempt_count_sub
>    9.21%  [kernel]                    [k] nf_ct_iterate_cleanup
>    3.15%  [kernel]                    [k] _raw_spin_unlock
>    2.80%  [kernel]                    [k] nf_conntrack_lock
>    2.67%  [kernel]                    [k] in_lock_functions
>    2.63%  [kernel]                    [k] get_parent_ip
>    2.26%  [kernel]                    [k] __inet_del_ifa
>    2.17%  [kernel]                    [k] fib_del_ifaddr
>    1.77%  [kernel]                    [k] _cond_resched
