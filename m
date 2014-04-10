From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Does IPv6 support Jumbograms ?
Date: Thu, 10 Apr 2014 15:28:42 +0200
Message-ID: <20140410132842.GI27255@order.stressinduktion.org>
References: <5345A2B3.7040602@gmail.com> <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com> <20140409223546.GH27255@order.stressinduktion.org> <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Francois WELLENREITER <f.wellenreiter@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35113 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030658AbaDJN2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 09:28:44 -0400
Content-Disposition: inline
In-Reply-To: <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 09, 2014 at 05:36:10PM -0700, Eric Dumazet wrote:
> On Thu, 2014-04-10 at 00:35 +0200, Hannes Frederic Sowa wrote:
> > On Wed, Apr 09, 2014 at 02:41:05PM -0700, Eric Dumazet wrote:
> > > What do you mean by blocked ?
> > > 
> > > Please give more details (kernel version, exact mtu...), because it
> > > should not happen !
> > > 
> > > # ifconfig lo mtu 100000
> > > # scp -6 vmlinux edumazet@ip6-localhost:/tmp
> > > Password: 
> > > vmlinux
> > > 100%   24MB  23.5MB/s   00:00    
> > > # ls -l /tmp/vmlinux
> > > -rwxr-xr-x 1 edumazet eng 24668915 Apr  9 14:37 /tmp/vmlinux
> > 
> > I couldn't test it on my development system with a recent net-next kernel
> > yet, but on my laptop with a distribution 3.13.9 kernel this happened too.
> 
> Oh well, it seems ip6_mtu() needs to cap mtu to max mtu for non
> jumbograms...
> 
> -	return mtu;
> +	return min_t(unsigned int, mtu, IP6_MAX_MTU);
> 
> #define IP6_MAX_MTU (65535 + 40)

I thought ip6_default_advmss will deal with this which correctly limits the
mtu. Capping dst_mtu would make it harder to implement jumbograms some day.

I'll look into it, thank you.
