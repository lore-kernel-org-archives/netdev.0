From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: /proc/net/sockstat invalid memory accounting or memory leak in
 latest kernels?
Date: Fri, 18 Jul 2014 10:41:37 +0200
Message-ID: <1405672897.10255.95.camel@edumazet-glaptop2.roam.corp.google.com>
References: <40bc2b5fcda47d790f1fd247bc409041@visp.net.lb>
	 <1405597918.10255.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <37e25a5815a18a2da507a5b20b58427d@visp.net.lb>
	 <1405604568.10255.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <a927787503c2f0d71c330b879303b14f@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:49841 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980AbaGRIln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2014 04:41:43 -0400
Received: by mail-wi0-f171.google.com with SMTP id hi2so447784wib.4
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2014 01:41:41 -0700 (PDT)
In-Reply-To: <a927787503c2f0d71c330b879303b14f@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-07-18 at 11:12 +0300, Denys Fedoryshchenko wrote:
> More updates. Now i found out how to see if tcp are under memory 
> pressure mode, i guess when it is active, speed might degrade. Now 
> almost all sockets are released, is it normal that tcp pressure still 
> "yes" ?
> 
> balancer-backup ~ # cat /proc/net/protocols
> protocol  size sockets  memory press maxhdr  slab module     cl co di ac 
> io in de sh ss gs se re sp bi br ha uh gp em
> PACKET    1216      0      -1   NI       0   no   kernel      n  n  n  n 
>   n  n  n  n  n  n  n  n  n  n  n  n  n  n  n
> ALG        624      0       0   NI       0   no   kernel      n  n  n  n 
>   n  n  n  n  n  n  n  n  n  n  n  n  n  n  n
> UNIX       832      1      -1   NI       0   yes  kernel      n  n  n  n 
>   n  n  n  n  n  n  n  n  n  n  n  n  n  n  n
> UDP-Lite   800      0      -1   NI       0   yes  kernel      y  y  y  n 
>   y  y  y  n  y  y  y  y  y  n  y  y  y  y  n
> PING       760      0      -1   NI       0   yes  kernel      y  y  y  n 
>   n  y  n  n  y  y  y  y  n  y  y  y  y  y  n
> RAW        768      0      -1   NI       0   yes  kernel      y  y  y  n 
>   y  y  y  n  y  y  y  y  n  y  y  y  y  n  n
> UDP        800      1       0   NI       0   yes  kernel      y  y  y  n 
>   y  n  y  n  y  y  y  y  y  n  y  y  y  y  n
> TCP       1608     24  1823119   yes    208   yes  kernel      y  y  y  
> y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
> NETLINK    992      0      -1   NI       0   no   kernel      n  n  n  n 
>   n  n  n  n  n  n  n  n  n  n  n  n  n  n  n
> balancer-backup ~ # cat /proc/net/sockstat
> sockets: used 51
> TCP: inuse 21 orphan 13 tw 2 alloc 21 mem 1823120
> UDP: inuse 1 mem 0
> UDPLITE: inuse 0
> RAW: inuse 0
> FRAG: inuse 0 memory


tcp believes its under pressure because of some bug on accounting.

If you change /proc/sys/net/ipv4/tcp_mem   (3rd value), it might say it
is not under pressure.

I am taking a look, thanks again for the report.
