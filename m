From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Sun, 6 Mar 2016 20:06:41 +0300
Message-ID: <20160306170641.GA8820@uranus.lan>
References: <1457136510.2761.8.camel@edumazet-ThinkPad-T530>
 <20160304.231109.1838919633640757059.davem@davemloft.net>
 <20160306100932.GP4184@uranus.lan>
 <1457281392.2663.5.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	solar@openwall.com, vvs@virtuozzo.com, avagin@virtuozzo.com,
	xemul@virtuozzo.com, vdavydov@virtuozzo.com, khorenko@virtuozzo.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:33891 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbcCFRGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 12:06:49 -0500
Received: by mail-lb0-f179.google.com with SMTP id xr8so11079852lbb.1
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2016 09:06:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1457281392.2663.5.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 06, 2016 at 08:23:12AM -0800, Eric Dumazet wrote:
> On dim., 2016-03-06 at 13:09 +0300, Cyrill Gorcunov wrote:
> 
> > Anyway, then I run this script for 255 as parameter
> > in one pass which gen. requests to create 65025 addresses
> > and kernel start complaining:
> > 
> > Perf output
> > -----------
> >   24.95%  [kernel]                      [k] __local_bh_enable_ip
> >   21.52%  [kernel]                      [k] lock_acquire
> >   15.54%  [kernel]                      [k] lock_release
> >    9.84%  [kernel]                      [k] lock_is_held
> >    7.47%  [kernel]                      [k] lock_acquired
> >    4.08%  [kernel]                      [k] __local_bh_disable_ip
> 
> Well, this looks like LOCKDEP kernel. Are you really running LOCKDEP on
> production kernels ?

This is vanilla kernel with most of debug features turned on,
not our production one. IIRC in production we don't use
lockdep. I can run tests with lockdep turned off. Still
I think I have to run tests on real hardware instead of
VM to provide you back some sane numbers, and once we
get back from holidays (which will be at Wednesday) I
gonna build the vanilla and run it on real machine
with both David's patches and measure the latency.
