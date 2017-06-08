From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: add TCPMemoryPressuresChrono counter
Date: Thu, 08 Jun 2017 11:26:39 -0400 (EDT)
Message-ID: <20170608.112639.1539826730157752352.davem@davemloft.net>
References: <1496776767.736.11.camel@edumazet-glaptop3.roam.corp.google.com>
        <1496867352.736.45.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58404 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751597AbdFHP0l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 11:26:41 -0400
In-Reply-To: <1496867352.736.45.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Jun 2017 13:29:12 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> DRAM supply shortage and poor memory pressure tracking in TCP
> stack makes any change in SO_SNDBUF/SO_RCVBUF (or equivalent autotuning
> limits) and tcp_mem[] quite hazardous.
> 
> TCPMemoryPressures SNMP counter is an indication of tcp_mem sysctl
> limits being hit, but only tracking number of transitions.
> 
> If TCP stack behavior under stress was perfect :
> 1) It would maintain memory usage close to the limit.
> 2) Memory pressure state would be entered for short times.
> 
> We certainly prefer 100 events lasting 10ms compared to one event
> lasting 200 seconds.
> 
> This patch adds a new SNMP counter tracking cumulative duration of
> memory pressure events, given in ms units.
> 
> $ cat /proc/sys/net/ipv4/tcp_mem
> 3088    4117    6176
> $ grep TCP /proc/net/sockstat
> TCP: inuse 180 orphan 0 tw 2 alloc 234 mem 4140
> $ nstat -n ; sleep 10 ; nstat |grep Pressure
> TcpExtTCPMemoryPressures        1700
> TcpExtTCPMemoryPressuresChrono  5209
> 
> v2: Used EXPORT_SYMBOL_GPL() instead of EXPORT_SYMBOL() as David
> instructed.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
