From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv6 routing table max_size badly dimensioned compared to IPv4
Date: Thu, 27 Feb 2014 11:59:04 -0800
Message-ID: <1393531144.26794.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140227192403.GA13472@xs.powerdns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bert hubert <bert.hubert@netherlabs.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:53198 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbaB0T7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 14:59:06 -0500
Received: by mail-pa0-f48.google.com with SMTP id kx10so2942232pab.35
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 11:59:05 -0800 (PST)
In-Reply-To: <20140227192403.GA13472@xs.powerdns.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-27 at 20:24 +0100, bert hubert wrote:
> Hi everybody,
> 
> Today, a PowerDNS (open source dns, www.powerdns.com) deployment ran into
> trouble with large amounts of IPv6 users.  It appears a large telco 'flicked
> the switch'.  We had around 8000 DNS queries/s over IPv6, and everything
> slowed to a crawl.  100% CPU utilization, most of it in the kernel. The same
> amount of queries over IPv4 causes no problems.
> 
> Note, this system is not functioning as a router or anything. It is just
> serving IPv6 DNS to a reasonable number of clients.
> 
> Thanks to diligent debugging and rapid help from friends over at SUSE, who
> suggested setting net.ipv6.route.max_size to a higher than default value,
> all problems were quickly resolved (thanks!).
> 
> From a quick reading of ip6_dst_gc, it is obvious that exceeding the
> max_size of the IPv6 routing table quickly becomes painful, causing non-stop
> gc scans.
> 
> net.ipv6.route.max_size defaults to 4096. The equivalent setting for IPv4
> defaults to 'millions' or is even dynamically sizing in modern kernels.
> 
> Now I know distributions can set this sysctl at will, but it appears that
> many of them don't. It does appear odd that we still assume at a kernel
> level that IPv6 is 'rare', a thousand times more rare than IPv4.
> 
> If people think this is a good idea, I could try to lift some of the other
> 'autosizing' code out there to get the IPv6 max_size limit raised on
> non-contrained hardware. 
> 
> Please let me know!
> 

What kernel version do you use ?

I thought this was already solved.

Commit 957c665f37007de93ccbe45902a23143724170d0 is in linux 3.0
("ipv6: Don't put artificial limit on routing table size.")
