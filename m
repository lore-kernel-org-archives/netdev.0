From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: restrict net.ipv4.tcp_adv_win_scale (#20312)
Date: Sun, 28 Nov 2010 10:39:20 -0800 (PST)
Message-ID: <20101128.103920.226762370.davem@davemloft.net>
References: <20101114201458.GA28181@core2.telecom.by>
	<1289830722.2586.5.camel@bwh-desktop>
	<20101122225421.GA7372@core2.telecom.by>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, bhutchings@solarflare.com
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54746
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753859Ab0K1Siy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 13:38:54 -0500
In-Reply-To: <20101122225421.GA7372@core2.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 23 Nov 2010 00:54:21 +0200

> tcp_win_from_space() does the following:
> 
>       if (sysctl_tcp_adv_win_scale <= 0)
>               return space >> (-sysctl_tcp_adv_win_scale);
>       else
>               return space - (space >> sysctl_tcp_adv_win_scale);
> 
> "space" is int.
> 
> As per C99 6.5.7 (3) shifting int for 32 or more bits is
> undefined behaviour.
> 
> Indeed, if sysctl_tcp_adv_win_scale is exactly 32,
> space >> 32 equals space and function returns 0.
> 
> Which means we busyloop in tcp_fixup_rcvbuf().
> 
> Restrict net.ipv4.tcp_adv_win_scale to [-31, 31].
> 
> Fix https://bugzilla.kernel.org/show_bug.cgi?id=20312
> 
> Steps to reproduce:
> 
>       echo 32 >/proc/sys/net/ipv4/tcp_adv_win_scale
>       wget www.kernel.org
>       [softlockup]
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

I'll aply this, thanks Alexey.
