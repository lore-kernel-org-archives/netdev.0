From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Remove unnecessary code from rt_check_expire().
Date: Tue, 26 Jun 2012 11:11:33 +0200
Message-ID: <1340701893.10893.296.camel@edumazet-glaptop>
References: <1340698984.10893.248.camel@edumazet-glaptop>
	 <20120626.013730.902797211256084220.davem@davemloft.net>
	 <1340700408.10893.275.camel@edumazet-glaptop>
	 <20120626.015612.985388265386248330.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:44135 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928Ab2FZJLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 05:11:38 -0400
Received: by eeit10 with SMTP id t10so1520941eei.19
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 02:11:37 -0700 (PDT)
In-Reply-To: <20120626.015612.985388265386248330.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 01:56 -0700, David Miller wrote:

> Keep in mind that rt_check_expire() was written before we had realtime
> GC.  It used to be main component which kept hash chains of reasonable
> size before real ->gc() triggers.
> 
> I have about 15 entries in my routing cache, there is no reason they
> should be purged.
> 
> And consider TCP before early demux, so a connection doing financial
> trades is idle for 5 minutes.  Do you really think the next trade
> should have this pointless added latency just because we can't be
> bothered to make rt_check_expired() smarter?

We did a lot of work in this area, for example making this gc running in
process context instead of timer, and removing the ip_rt_secret_interval
that was invalidating the whole cache every 10 minutes.

I think I stopped trying to improve route cache because your intention
was to get rid of it.

Now it seems we should keep it for a while, so it makes sense to add
more fuel on it ;)

About financial guys, they probably are smart enough to :

echo bigvalue >/proc/sys/net/ipv4/route/gc_timeout

(although the cache misses on old cached dst might kill their latency
anyway)
