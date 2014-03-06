From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] ipv6: don't set DST_NOCOUNT for remotely added routes
Date: Thu, 6 Mar 2014 22:03:17 +0100
Message-ID: <20140306210317.GA9952@kria>
References: <1394124717-1957-1-git-send-email-sd@queasysnail.net>
 <20140306.152715.1223513898002005603.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:43067 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750924AbaCFVD3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 16:03:29 -0500
Content-Disposition: inline
In-Reply-To: <20140306.152715.1223513898002005603.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-06, 15:27:15 -0500, David Miller wrote:
> From: Sabrina Dubroca <sd@queasysnail.net>
> Date: Thu,  6 Mar 2014 17:51:57 +0100
> 
> > DST_NOCOUNT should only be used if an authorized user adds routes
> > locally. In case of routes which are added on behalf of router
> > advertisments this flag must not get used as it allows an unlimited
> > number of routes getting added remotely.
> > 
> > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> > 
> > Hannes suggested this for stable
> 
> This seems to conflict with the intentions of:
> 
> commit a3300ef4bbb1f1e33ff0400e1e6cf7733d988f4f
> Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date:   Sat Dec 7 03:33:45 2013 +0100
> 
>     ipv6: don't count addrconf generated routes against gc limit
> 
> If not, why not?

These are not the same routes. The commit you mention is for the
routes added to the loopback device in the local table (limited by
max_addresses as the log says).

This patch limits the number of "real" routes that can be added,
which is currently unlimited.

-- 
Sabrina
