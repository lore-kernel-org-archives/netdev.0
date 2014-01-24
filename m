From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [net/loopback] +46% netperf.Throughput_Mbps
Date: Fri, 24 Jan 2014 20:24:42 +0800
Message-ID: <20140124122442.GA27801@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16254 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752167AbaAXMYo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jan 2014 07:24:44 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Just FYI, we do measured +46.4% performance boost in netperf
TCP_SENDFILE tests on an atom server for commit:

commit 0cf833aefaa85bbfce3ff70485e5534e09254773
Author:     Eric Dumazet <edumazet@google.com>
AuthorDate: Sun Sep 23 22:28:59 2012 +0000
Commit:     David S. Miller <davem@davemloft.net>
CommitDate: Mon Sep 24 16:23:53 2012 -0400

    net: loopback: set default mtu to 64K
    
    loopback current mtu of 16436 bytes allows no more than 3 MSS TCP
    segments per frame, or 48 Kbytes. Changing mtu to 64K allows TCP
    stack to build large frames and significantly reduces stack overhead.
    
    Performance boost on bulk TCP transferts can be up to 30 %, partly
    because we now have one ACK message for two 64KB segments, and a lower
    probability of hitting /proc/sys/net/ipv4/tcp_reordering default limit.
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

 drivers/net/loopback.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

2a6c8c7998f95b1  0cf833aefaa85bbfce3ff7048  
---------------  -------------------------  
      1233 ~ 4%     +46.4%       1805 ~ 0%   netperf.Throughput_Mbps
     29214 ~ 9%     -85.2%       4310 ~17%   interrupts.RES
    450970 ~ 3%     -57.3%     192675 ~ 1%   proc-vmstat.pgalloc_normal
    453096 ~ 3%     -57.0%     194790 ~ 1%   proc-vmstat.pgfree
   4664799 ~ 6%     -47.7%    2441398 ~ 0%   softirqs.NET_RX
      1107 ~ 9%     +62.2%       1797 ~ 0%   slabinfo.kmalloc-1024.active_objs
      1185 ~ 8%     +54.2%       1827 ~ 0%   slabinfo.kmalloc-1024.num_objs
    244825 ~ 3%     -28.6%     174791 ~ 0%   proc-vmstat.numa_hit
    244825 ~ 3%     -28.6%     174791 ~ 0%   proc-vmstat.numa_local
       913 ~ 2%     +39.3%       1271 ~ 1%   slabinfo.skbuff_fclone_cache.active_objs
       944 ~ 3%     +36.9%       1293 ~ 1%   slabinfo.skbuff_fclone_cache.num_objs
        10 ~ 0%     -10.0%          9 ~ 0%   vmstat.procs.r
     59630 ~12%     -94.4%       3336 ~ 8%   vmstat.system.cs
      1233 ~ 1%     -16.4%       1031 ~ 0%   vmstat.system.in

                               netperf.Throughput_Mbps

   2000 ++------------------------------------------------------------------+
   1800 O+O O  O O O O O  O O O O O  O O O O O O  O O O O O  O O O O O  O O O
        |                                                                   |
   1600 ++                                                                  |
   1400 ++                  *.                                              |
        *.*.*..   .*.*.    +  *      *.*.*.*.    .*.*. .*.*                 |
   1200 ++     *.*     *..*   :      :       *.*.     *                     |
   1000 ++                    :     :                                       |
    800 ++                     :    :                                       |
        |                      :    :                                       |
    600 ++                     :   :                                        |
    400 ++                     :   :                                        |
        |                       :  :                                        |
    200 ++                      : :                                         |
      0 ++----------------------*-*-----------------------------------------+
