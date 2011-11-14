From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] ipv6: reduce percpu needs for icmpv6msg mibs
Date: Mon, 14 Nov 2011 08:12:53 -0800
Message-ID: <20111114081253.226e2b66@nehalam.linuxnetplumber.net>
References: <1321183444.17837.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52949 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751432Ab1KNQMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 11:12:55 -0500
In-Reply-To: <1321183444.17837.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Nov 2011 12:24:04 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Reading /proc/net/snmp6 on a machine with a lot of cpus is very
> expensive (can be ~88000 us).
> 
> This is because ICMPV6MSG MIB uses 4096 bytes per cpu, and folding
> values for all possible cpus can read 16 Mbytes of memory (32MBytes on
> non x86 arches)
> 
> ICMP messages are not considered as fast path on a typical server, and
> eventually few cpus handle them anyway. We can afford an atomic
> operation instead of using percpu data.
> 
> This saves 4096 bytes per cpu and per network namespace.

Probably should do this for ICMP for IPv4 and all the other
non hot counters. The whole per-cpu SNMP MIB stuff for all counters
is massive overkill.
