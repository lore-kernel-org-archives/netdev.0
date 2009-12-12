From: David Miller <davem@davemloft.net>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Sat, 12 Dec 2009 01:03:40 -0800 (PST)
Message-ID: <20091212.010340.227842186.davem@davemloft.net>
References: <alpine.DEB.2.01.0912112335440.2915@bogon.housecafe.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: lists@nerdbynature.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758452AbZLLJDk@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.01.0912112335440.2915@bogon.housecafe.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christian Kujau <lists@nerdbynature.de>
Date: Fri, 11 Dec 2009 23:43:10 -0800 (PST)

> today I upgraded from 2.6.32-rc7 to the latest -git (mainline) and after a 
> few hours the messages below appeared in the log. Apparently "privoxy" was 
> very busy handling connections, but the messages never appeared with 
> earlier kernels. 
> 
> Full dmesg & .config is on:
> http://nerdbynature.de/bits/2.6.33-git/inet_accept/

Yeah I started seeing this on one of my machines too, the
assertion is:

	WARN_ON(newsk->sk_state == TCP_SYN_RECV);

I wonder if some of the refactorings we did to allow per-route
SACK/DSACK/etc. controls messed some sequence of state changes
on TCP sockets.  But I can't find anything obvious in those
commits.
