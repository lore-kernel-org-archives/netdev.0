From: Rick Jones <rick.jones2@hp.com>
Subject: Re: setsockopt()
Date: Mon, 07 Jul 2008 16:27:14 -0700
Message-ID: <4872A652.2050709@hp.com>
References: <20080707142408.43aa2a2e@extreme> <48728B09.1050801@citi.umich.edu>	<48729DAD.8010400@hp.com> <20080707.160029.13296246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: aglo@citi.umich.edu, shemminger@vyatta.com, netdev@vger.kernel.org,
	rees@umich.edu, bfields@fieldses.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:2408 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754209AbYGGX1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 19:27:22 -0400
In-Reply-To: <20080707.160029.13296246.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> We need 2x, in order to have a full window during recovery.
> 
> There was a measurement bug found a few months ago when the
> google folks were probing in this area, which was fixed
> by John Heffner.  Most of which had to deal with TSO subtleties.
> 
> --------------------
> commit 246eb2af060fc32650f07203c02bdc0456ad76c7
> Author: John Heffner <johnwheffner@gmail.com>
> Date:   Tue Apr 29 03:13:52 2008 -0700
> 
>     tcp: Limit cwnd growth when deferring for GSO
>     
>     This fixes inappropriately large cwnd growth on sender-limited flows
>     when GSO is enabled, limiting cwnd growth to 64k.
>     
>     Signed-off-by: John Heffner <johnwheffner@gmail.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> commit ce447eb91409225f8a488f6b7b2a1bdf7b2d884f
> Author: John Heffner <johnwheffner@gmail.com>
> Date:   Tue Apr 29 03:13:02 2008 -0700
> 
>     tcp: Allow send-limited cwnd to grow up to max_burst when gso disabled
>     
>     This changes the logic in tcp_is_cwnd_limited() so that cwnd may grow
>     up to tcp_max_burst() even when sk_can_gso() is false, or when
>     sysctl_tcp_tso_win_divisor != 0.
>     
>     Signed-off-by: John Heffner <johnwheffner@gmail.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> --------------------


I'll try my tests again with newer kernels since I'm not 100% certain I 
was trying with those commits in place.

> Setting TCP socket buffer via setsockopt() is always wrong.

Does that apply equally to SO_SNDBUF and SO_RCVBUF?

rick jones
