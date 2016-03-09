From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Wed, 9 Mar 2016 20:09:21 +0300
Message-ID: <20160309170921.GL2207@uranus.lan>
References: <1457136510.2761.8.camel@edumazet-ThinkPad-T530>
 <20160304.231109.1838919633640757059.davem@davemloft.net>
 <20160306100932.GP4184@uranus.lan>
 <1457281392.2663.5.camel@edumazet-ThinkPad-T530>
 <20160306170641.GA8820@uranus.lan>
 <20160309163919.GJ2207@uranus.lan>
 <20160309165850.GA49579@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	solar@openwall.com, vvs@virtuozzo.com, avagin@virtuozzo.com,
	xemul@virtuozzo.com, vdavydov@virtuozzo.com, khorenko@virtuozzo.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:35830 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbcCIRJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 12:09:27 -0500
Received: by mail-lb0-f176.google.com with SMTP id bc4so74634172lbc.2
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 09:09:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160309165850.GA49579@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 09, 2016 at 08:58:52AM -0800, Alexei Starovoitov wrote:
...
> 
> above line is an indication that you have:
> #if defined(CONFIG_DEBUG_PREEMPT) || defined(CONFIG_PREEMPT_TRACER)
> turning it off will speed up things significantly.

Look, this won't change the overall picture. For sure it will
speedup the kernel but it won't prevent the users from allowing
allocating addresses. So timings will drop a bit but the main
issue will remain -- there is no explicit way to limit this
resource. We can create say 1K of netnamespaces and allocate
100K addresses in each, then start destorying the namespaces
and node gonna be unreachable until everything is freed. The
kernel works as it shold simply in case of highload is stops
react due to big number of rtnl-locks taken.

	Cyrill
