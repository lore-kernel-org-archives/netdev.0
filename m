From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Limit mtu to 65572 bytes
Date: Thu, 10 Apr 2014 18:58:45 -0700
Message-ID: <1397181525.16584.70.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5345A2B3.7040602@gmail.com>
	 <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140409223546.GH27255@order.stressinduktion.org>
	 <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140410235459.GK27255@order.stressinduktion.org>
	 <1397176824.16584.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Francois WELLENREITER <f.wellenreiter@gmail.com>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:56231 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294AbaDKB6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 21:58:48 -0400
Received: by mail-pb0-f45.google.com with SMTP id uo5so4729859pbc.4
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2014 18:58:48 -0700 (PDT)
In-Reply-To: <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-04-10 at 18:42 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Francois reported that setting big mtu on loopback device could prevent
> tcp sessions making progress.
> 
> We do not support (yet ?) IPv6 Jumbograms and cook corrupted packets.
> 
> We must limit the IPv6 MTU to (65535 + 40) bytes in theory.
> 
> In practice, its better to align to a multiple of 4 for optimal TCP
> performance.

Same story for IPv4 btw : current lo mtu=65536 is suboptimal


lpq83:~# ifconfig lo mtu 65536
lpq83:~# ./netperf 
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
localhost () port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.00    33020.76   


lpq83:~# ifconfig lo mtu 65533
lpq83:~# ./netperf 
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
localhost () port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.00    39010.09   
