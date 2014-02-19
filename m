From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next] net: tcp: add mib counters to track zero window
 transitions
Date: Wed, 19 Feb 2014 11:46:49 -0800
Message-ID: <1392839209.18849.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392674268-26005-1-git-send-email-fw@strlen.de>
	 <20140219.131708.562226572566677127.davem@davemloft.net>
	 <1392835787.18849.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140219185949.GA1179@order.stressinduktion.org>
	 <20140219191831.GA7119@breakpoint.cc>
	 <20140219193038.GC1179@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:53527 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754486AbaBSTqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 14:46:50 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so794395pde.6
        for <netdev@vger.kernel.org>; Wed, 19 Feb 2014 11:46:50 -0800 (PST)
In-Reply-To: <20140219193038.GC1179@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-19 at 20:30 +0100, Hannes Frederic Sowa wrote:

> NET_STATS only use 32 bit counter and thus need not be protected with a
> seqlock on 32 bit platforms. As such, it does not matter, but e.g. the IP
> counter are prone to deadlocks if used with wrong postfix because of 64 bit
> counter thus protected by seqlock.
> 
> A pitty that the _STATS_BH postfixes have the opposite meaning of the bottom
> _bh postfixes.
> 
> Basically always safe is _STATS and if we are sure we can omit the bh disable
> call because we only call the function from bh, we can use _STATS_BH calls.

Using __this_cpu_inc() is not safe in preemptable contexts.

Sure, x86 doesn't care, but other arches might.

Fortunately LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES can be incremented
only for a retransmit, and they should always happen from BH.

Better avoid the confusion for this ultra rare case, I'll send a patch.
