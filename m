From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Remove unnecessary code from rt_check_expire().
Date: Tue, 26 Jun 2012 10:23:04 +0200
Message-ID: <1340698984.10893.248.camel@edumazet-glaptop>
References: <20120626.002124.2220875506847485306.davem@davemloft.net>
	 <1340696398.10893.209.camel@edumazet-glaptop>
	 <20120626.004658.2123525722448546355.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61957 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754696Ab2FZIXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 04:23:09 -0400
Received: by bkcji2 with SMTP id ji2so3900741bkc.19
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 01:23:07 -0700 (PDT)
In-Reply-To: <20120626.004658.2123525722448546355.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 00:46 -0700, David Miller wrote:

> And for legitimate traffic it's completely the wrong thing to do.
> 
> There is absolutely zero reason to pure valid entries when hash chains
> average length of one.
> 
> I've been monitoring routing cache activity, and it's the height of
> stupidity.  Every 5 minutes we pure, and then they all get regenerated
> again.
> 

Thats because gc_interval (60) is big compared to ip_rt_gc_timeout
(300)

So each time rt_check_expire() triggers, we handle a big part of the
cache. On big servers I had to lower gc_interval to smooth things.

Garbage collect is needed to not waste kernel memory, even on legitimate
traffic on a typical web server.

Taken from my 8GB machine : 

# cat /proc/sys/net/ipv4/route/gc_thresh
262144

320 bytes per dst : 262144*320 = 83886080 bytes to store one dst per hash chain.

Also, why keeping a dst in cache if no traffic uses it in a 5 minutes period ?
