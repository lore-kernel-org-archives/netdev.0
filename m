From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG] ipv6 and TSO on GRE is broken
Date: Wed, 01 May 2013 08:53:42 -0700
Message-ID: <1367423622.11020.54.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>,
	"Steinar H. Gunderson" <sesse@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:49245 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761541Ab3EAPxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 11:53:45 -0400
Received: by mail-pd0-f182.google.com with SMTP id 14so874275pdj.41
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 08:53:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was reported by Steinar.

Sending this to netdev, as I wont have time to debug this in the near
future. (~ 3 days)

3.9 and latest net-next are broken for IPv6 on top of GRE tunnel

GSO seems OK, but TSO not :

lpq83:~# ethtool -K gre1 tso off gso on 
lpq83:~# netperf -H 4444::555:0084
MIGRATED TCP STREAM TEST from ::0 (::) port 0 AF_INET6 to 4444::555:0084
() port 0 AF_INET6
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.00    3789.10   
lpq83:~# ethtool -K gre1 tso on
lpq83:~# netperf -H 4444::555:0084
MIGRATED TCP STREAM TEST from ::0 (::) port 0 AF_INET6 to 4444::555:0084
() port 0 AF_INET6
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.00     321.27   


No problem for IPv4

Thanks
