From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] tcp: sysctl for initial receive window
Date: Fri, 21 Sep 2012 20:32:06 +0200
Message-ID: <1348252326.3103.90.camel@localhost>
References: <20120921085502.4534.20232.stgit@dragon>
	 <1348241111.2669.580.camel@edumazet-glaptop>
	 <20120921.135601.254379488076661898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, nanditad@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8388 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755071Ab2IUScL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2012 14:32:11 -0400
In-Reply-To: <20120921.135601.254379488076661898.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-21 at 13:56 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 21 Sep 2012 17:25:11 +0200
> 
> > On Fri, 2012-09-21 at 10:55 +0200, Jesper Dangaard Brouer wrote:
> >> Make it possible to adjust the TCP default initial advertised receive
> >> window, via sysctl /proc/sys/net/ipv4/tcp_init_recv_window.
> >> 
> >> The window size is this value multiplied by the MSS of the connection.
> >> The default value is (still) 10, as descibed in commit 356f039822b
> >> (TCP: increase default initial receive window.)
> >> 
> >> Allow minimum value of 1, but recommend against setting value below 2
> >> in the documentation.
> >> 
> >> Its possible to control/override this value per route table entry via
> >> the iproute2 option initrwnd.  Having the global default exported via
> >> sysctl, helps determine the default setting, and make is easier to
> >> adjust.
> > 
> > I was wondering why its not symmetric :
> > 
> > If we add a sysctl for initial receive window, we need another one for
> > initial send window ?
> 
> Unlike the routing configuration, this is susceptible to serious abuse.

Are you talking about, this patch for "tcp_init_recv_window" initial
advertised receive window?


> All it takes is for one jackass vendor to say that this should be set
> to 1,000 in in sysctl.conf when using their product.

I do see your point with jackass vendors.

But (for tcp_init_recv_window) its not a problem, because this is being
limited by tcp_rmem[1] (and div 2 default due to tcp_adv_win_scale), and
can/is further be limited by window clamping. (and we also cut it if
tcp_adv_win_scale > 14).


> Whereas setting it on a per-route basis forces the person doing it
> to actually consider that there might be ramifications that have to
> do with the paths on which you are making this adjustment.

As I mentioned above, this also requires some extra work and
consideration to make this go out of bound.

> I would only let this in if you hard limited the setting to it's
> current setting, 10.  So people could decrease it.

The would defeat the purpose of the patch.  Perhaps we could, allow a
sensible max... (but this max is already being controlled as described).


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
